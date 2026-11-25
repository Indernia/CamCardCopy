import Observation

/// Counts pushed pages on screen; the tab bar is hidden while any is shown (fix-pushed-page-chrome D2).
@Observable
@MainActor
final class TabBarVisibility {
    private(set) var pushedPages = 0

    var isHidden: Bool { pushedPages > 0 }

    func pageAppeared() {
        pushedPages += 1
    }

    func pageDisappeared() {
        pushedPages = max(0, pushedPages - 1)
    }
}
