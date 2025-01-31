// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import AlphaWalletFoundation

protocol EnterPasswordCoordinatorDelegate: AnyObject {
    func didEnterPassword(password: String, account: AlphaWallet.Address, in coordinator: EnterPasswordCoordinator)
    func didCancel(in coordinator: EnterPasswordCoordinator)
}

class EnterPasswordCoordinator: CoordinatorThatEnds {
    private lazy var rootViewController: KeystoreBackupIntroductionViewController = {
        let controller = KeystoreBackupIntroductionViewController()
        controller.delegate = self
        controller.configure()
        return controller
    }()
    private let account: AlphaWallet.Address

    let navigationController: UINavigationController
    var coordinators: [Coordinator] = []
    weak var delegate: EnterPasswordCoordinatorDelegate?

    init(
        navigationController: UINavigationController = NavigationController(),
        account: AlphaWallet.Address
    ) {
        self.navigationController = navigationController
        self.account = account
    }

    func start() {
        rootViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(rootViewController, animated: true)
    }

    func end() {
        //do nothing
    }

    func endUserInterface(animated: Bool) {
        let _ = navigationController.viewControllers.firstIndex(of: rootViewController)
                .flatMap { navigationController.viewControllers[$0 - 1] }
                .flatMap { navigationController.popToViewController($0, animated: animated) }
    }
}

extension EnterPasswordCoordinator: KeystoreBackupIntroductionViewControllerDelegate {
    func didTapExport(inViewController viewController: KeystoreBackupIntroductionViewController) {
        let controller = EnterKeystorePasswordViewController(viewModel: EnterKeystorePasswordViewModel())
        controller.delegate = self
        controller.navigationItem.largeTitleDisplayMode = .never

        navigationController.pushViewController(controller, animated: true)
    }
}

extension EnterPasswordCoordinator: EnterKeystorePasswordViewControllerDelegate {

    func didEnterPassword(password: String, in viewController: EnterKeystorePasswordViewController) {
        delegate?.didEnterPassword(password: password, account: account, in: self)
    }
}
