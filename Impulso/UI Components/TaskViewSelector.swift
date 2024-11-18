import SwiftUI

struct TaskViewSelector: View {
    @Binding var selection: TaskViewState
    let activeTasks: Int
    let completedTasks: Int
    let backlogTasks: Int
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 24) {
            ForEach([TaskViewState.active, .completed, .backlog], id: \.self) { state in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = state
                    }
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(state.title)
                            .font(.system(size: 13, weight: selection == state ? .semibold : .regular))
                        
                        if selection == state {
                            Text("\(countFor(state))")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(height: 32)
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(selection == state ? .primary : .secondary)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func countFor(_ state: TaskViewState) -> Int {
        switch state {
        case .active: return activeTasks
        case .completed: return completedTasks
        case .backlog: return backlogTasks
        }
    }
}

extension TaskViewState {
    var title: String {
        switch self {
        case .active: return "Active"
        case .completed: return "Completed"
        case .backlog: return "Backlog"
        }
    }
} 