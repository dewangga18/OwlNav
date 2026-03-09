//
//  OwlNavigationController
//  OwlNav
//
//  Created by aaronevanjulio on 06/03/26.
//

import SwiftUI

/// A custom `UINavigationController` that handles system pop gestures and coordinates with `OwlNav`.
final class OwlNavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    /// Callback triggered when a system pop (like swipe back) is initiated.
    var onSystemPop: (() -> Void)?

    /// Callback triggered when a system pop operation is completed.
    var onSystemPopCompleted: (() -> Void)?

    /// Internal flag to suppress the next system pop event signaling.
    private var suppressNextSystemPopEvent: Bool = false

    /// timestamp of the last transition completion to prevent rapid gestures.
    private var lastTransitionEndTime: CFTimeInterval = 0

    /// Minimum time between transitions.
    private let transitionCooldown: CFTimeInterval = 0.35

    /// Flag indicating if the current pop is being handled by the transition coordinator.
    private var popHandledByCoordinator: Bool = false

    /// Suppresses the next system pop event notification.
    func suppressNextSystemPop() {
        suppressNextSystemPopEvent = true
    }

    /// Configures the navigation controller for swipe-back gesture support.
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        interactivePopGestureRecognizer?.delegate = self
        interactivePopGestureRecognizer?.isEnabled = true
    }

    /// Determines if the interactive pop gesture should begin.
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard viewControllers.count > 1 else { return false }

        guard transitionCoordinator == nil else { return false }

        guard (CACurrentMediaTime() - lastTransitionEndTime) >= transitionCooldown else {
            return false
        }
        return true
    }

    /// Handles the transition to a new view controller.
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let coordinator = transitionCoordinator else {
            popHandledByCoordinator = false
            return
        }

        popHandledByCoordinator = true

        coordinator.animate(alongsideTransition: nil) { [weak self] context in
            guard let self, !context.isCancelled else { return }


            guard let fromVC = context.viewController(forKey: .from),
                  !self.viewControllers.contains(fromVC)
            else { return }

            if self.suppressNextSystemPopEvent {
                self.suppressNextSystemPopEvent = false
                self.onSystemPopCompleted = nil
                return
            }

            self.onSystemPop?()
            let completion = self.onSystemPopCompleted
            self.onSystemPopCompleted = nil
            completion?()
        }
    }

    /// Handles the completion of a transition to a new view controller.
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        lastTransitionEndTime = CACurrentMediaTime()
        
        if !popHandledByCoordinator, suppressNextSystemPopEvent {
            suppressNextSystemPopEvent = false
            onSystemPopCompleted = nil
        }
        popHandledByCoordinator = false
    }
}
