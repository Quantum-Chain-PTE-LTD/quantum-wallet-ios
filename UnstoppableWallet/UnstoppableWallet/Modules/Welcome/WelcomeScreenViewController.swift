import SnapKit
import SwiftUI
import UIKit

struct WelcomeScreenView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController

    let onFinish: () -> Void

    func makeUIViewController(context _: Context) -> UIViewController {
        WelcomeScreenViewController.instance(onFinish: onFinish)
    }

    func updateUIViewController(_: UIViewController, context _: Context) {}
}

// Quantum Wallet — mirrors Android 2698f57e: 2-second splash, no carousel.
class WelcomeScreenViewController: ThemeViewController {
    private static let splashDuration: TimeInterval = 2.0

    private let onFinish: () -> Void
    private let logoView = UIView()
    private var didAdvance = false

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
        super.init()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .themeTyler

        view.addSubview(logoView)
        logoView.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }

        let logoImageView = UIImageView()
        logoView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalToSuperview()
            maker.size.equalTo(120)
        }

        logoImageView.image = UIImage(named: AppIcon.main.imageName)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.cornerRadius = .cornerRadius16
        logoImageView.layer.cornerCurve = .continuous
        logoImageView.clipsToBounds = true

        let logoTitleLabel = UILabel()
        logoView.addSubview(logoTitleLabel)
        logoTitleLabel.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(logoImageView.snp.bottom).offset(28)
            maker.bottom.equalToSuperview()
        }

        logoTitleLabel.numberOfLines = 0
        logoTitleLabel.textAlignment = .center
        logoTitleLabel.font = .title2
        logoTitleLabel.textColor = .themeLeah
        logoTitleLabel.text = AppConfig.appName
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + Self.splashDuration) { [weak self] in
            guard let self, !self.didAdvance else { return }
            self.didAdvance = true
            self.onFinish()
        }
    }
}

extension WelcomeScreenViewController {
    static func instance(onFinish: @escaping () -> Void) -> UIViewController {
        WelcomeScreenViewController(onFinish: onFinish)
    }
}
