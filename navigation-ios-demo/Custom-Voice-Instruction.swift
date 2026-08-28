import AVFoundation
import UIKit
import NbmapNavigation
import NbmapCoreNavigation
import Nbmap

/// A complete custom voice-player example backed by `AVSpeechSynthesizer`.
///
/// Replace the body of `speak(_:during:locale:)` with an `AVAudioPlayer` or a
/// third-party TTS client to play prerecorded or remotely generated guidance.
final class CustomSpeechSynthesizer: NSObject, SpeechSynthesizing {
    weak var delegate: SpeechSynthesizingDelegate?

    var muted = false {
        didSet {
            if muted {
                stopSpeaking()
            }
        }
    }
    var volume: Float = 1.0
    var locale: Locale?

    /// Set this to `false` when the host application manages `AVAudioSession`.
    var managesAudioSession = true

    var isSpeaking: Bool {
        return systemSynthesizer.isSpeaking
    }

    private let preferredVoiceIdentifier: String?
    private let speechRate: Float
    private let systemSynthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?
    private var instructionsByUtterance: [ObjectIdentifier: SpokenInstruction] = [:]
    private var interruptedUtterances: Set<ObjectIdentifier> = []

    init(
        preferredVoiceIdentifier: String? = nil,
        speechRate: Float = AVSpeechUtteranceDefaultSpeechRate
    ) {
        self.preferredVoiceIdentifier = preferredVoiceIdentifier
        self.speechRate = speechRate
        super.init()
        systemSynthesizer.delegate = self
    }

    func prepareIncomingSpokenInstructions(_ instructions: [SpokenInstruction], locale: Locale?) {
        // A network-backed player can prefetch audio for `instructions` here.
        if let locale = locale {
            self.locale = locale
        }
    }

    func speak(
        _ instruction: SpokenInstruction,
        during legProgress: RouteLegProgress,
        locale: Locale?
    ) {
        guard !muted else { return }

        let instructionToSpeak: SpokenInstruction
        if let delegate = delegate {
            guard let updatedInstruction = delegate.speechSynthesizer(self, willSpeak: instruction) else {
                return
            }
            instructionToSpeak = updatedInstruction
        } else {
            instructionToSpeak = instruction
        }

        interruptCurrentInstruction(with: instructionToSpeak)
        activateAudioSession(for: instructionToSpeak)

        let utterance = AVSpeechUtterance(string: instructionToSpeak.text)
        utterance.rate = speechRate
        utterance.volume = min(max(volume, 0), 1)
        utterance.voice = voice(for: locale ?? self.locale)

        currentUtterance = utterance
        instructionsByUtterance[ObjectIdentifier(utterance)] = instructionToSpeak
        systemSynthesizer.speak(utterance)
    }

    func stopSpeaking() {
        guard systemSynthesizer.isSpeaking else {
            finishAudioSessionIfNeeded(for: nil)
            return
        }
        systemSynthesizer.stopSpeaking(at: .immediate)
    }

    func interruptSpeaking() {
        stopSpeaking()
    }

    private func voice(for locale: Locale?) -> AVSpeechSynthesisVoice? {
        if let identifier = preferredVoiceIdentifier,
           let voice = AVSpeechSynthesisVoice(identifier: identifier) {
            return voice
        }

        guard let locale = locale else { return nil }
        let language = locale.identifier.replacingOccurrences(of: "_", with: "-")
        return AVSpeechSynthesisVoice(language: language)
    }

    private func interruptCurrentInstruction(with newInstruction: SpokenInstruction) {
        guard let utterance = currentUtterance else { return }

        let identifier = ObjectIdentifier(utterance)
        guard let currentInstruction = instructionsByUtterance[identifier] else { return }

        interruptedUtterances.insert(identifier)
        delegate?.speechSynthesizer(
            self,
            didInterrupt: currentInstruction,
            with: newInstruction
        )

        if systemSynthesizer.isSpeaking {
            systemSynthesizer.stopSpeaking(at: .immediate)
        }
    }

    private func activateAudioSession(for instruction: SpokenInstruction) {
        guard managesAudioSession else { return }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(
                .playback,
                mode: .spokenAudio,
                options: [.duckOthers, .interruptSpokenAudioAndMixWithOthers]
            )
            try audioSession.setActive(true)
        } catch {
            let speechError = SpeechError.unableToControlAudio(
                instruction: instruction,
                action: .duck,
                underlying: error
            )
            delegate?.speechSynthesizer(self, encounteredError: speechError)
        }
    }

    private func finishAudioSessionIfNeeded(for instruction: SpokenInstruction?) {
        guard managesAudioSession,
              !systemSynthesizer.isSpeaking,
              instructionsByUtterance.isEmpty else {
            return
        }

        do {
            try AVAudioSession.sharedInstance().setActive(
                false,
                options: .notifyOthersOnDeactivation
            )
        } catch {
            let speechError = SpeechError.unableToControlAudio(
                instruction: instruction,
                action: .unduck,
                underlying: error
            )
            delegate?.speechSynthesizer(self, encounteredError: speechError)
        }
    }

    private func complete(_ utterance: AVSpeechUtterance, didFinish: Bool) {
        let identifier = ObjectIdentifier(utterance)
        let instruction = instructionsByUtterance.removeValue(forKey: identifier)
        let wasInterrupted = interruptedUtterances.remove(identifier) != nil

        if currentUtterance === utterance {
            currentUtterance = nil
        }

        if didFinish, !wasInterrupted, let instruction = instruction {
            delegate?.speechSynthesizer(self, didSpeak: instruction, with: nil)
        }

        finishAudioSessionIfNeeded(for: instruction)
    }
}

extension CustomSpeechSynthesizer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        complete(utterance, didFinish: true)
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        complete(utterance, didFinish: false)
    }
}

final class CustomVoiceInstructionController: UIViewController, VoiceControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

        let origin = CLLocation(latitude: 37.77440680146262, longitude: -122.43539772352648)
        let destination = CLLocation(latitude: 37.76556957793795, longitude: -122.42409811526268)
        let options = NavigationRouteOptions(origin: origin, destination: destination)

        Directions.shared.calculate(options) { [weak self] routes, error in
            guard let self = self else { return }

            if let error = error {
                print(error)
                return
            }
            guard let routes = routes else { return }

            let navigationService = NBNavigationService(
                routes: routes,
                routeIndex: 0,
                simulating: simulationIsEnabled ? .always : .inTunnels
            )

            // Inject any custom `SpeechSynthesizing` implementation here.
            let speechSynthesizer = CustomSpeechSynthesizer()
            let routeVoiceController = RouteVoiceController(speechSynthesizer: speechSynthesizer)
            routeVoiceController.voiceControllerDelegate = self

            let navigationOptions = NavigationOptions(
                navigationService: navigationService,
                voiceController: routeVoiceController
            )
            let navigationViewController = NavigationViewController(
                for: routes,
                navigationOptions: navigationOptions
            )
            navigationViewController.modalPresentationStyle = .fullScreen
            navigationViewController.routeLineTracksTraversal = true

            self.present(navigationViewController, animated: true)
        }
    }

    func voiceController(
        _ voiceController: RouteVoiceController,
        spokenInstructionsDidFailWith error: Error
    ) {
        print("Custom voice player failed: \(error)")
    }
}
