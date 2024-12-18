import SwiftUI

struct ImpulsoView: View {
    @ObservedObject var viewModel: ImpulsoViewModel
    @State private var showingCommandMenu = false
    @State private var hoveredTaskId: UUID?
    @FocusState private var isInputFieldFocused: Bool
    
    // Add this to handle keyboard shortcuts
    class KeyboardShortcuts {
        static func setup(action: @escaping () -> Void) -> NSObjectProtocol {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "n" {
                    action()
                    return nil
                }
                return event
            } as! NSObjectProtocol
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                TaskViewSelector(
                    selection: $viewModel.currentViewState,
                    activeTasks: viewModel.activeTaskCount,
                    completedTasks: viewModel.completedTaskCount,
                    backlogTasks: viewModel.backlogTaskCount,
                    viewModel: viewModel
                )
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: { showingCommandMenu = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 12))
                            Text("Search or create")
                                .font(.system(size: 12))
                            Text("⌘K")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.1))
                                .cornerRadius(4)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .keyboardShortcut("k", modifiers: .command)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
            
            // Add error display
            if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
            
            // Add loading indicator
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }
            
            // Add TaskInputField here
            TaskInputField(onSubmit: viewModel.addTask)
                .focused($isInputFieldFocused)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            
            // Task List
            if viewModel.tasks.isEmpty {
                emptyStateView
                    .modifier(StateDropAreaModifier(state: viewModel.currentViewState, viewModel: viewModel))
            } else {
                ScrollView {
                    LazyVStack(spacing: 8, pinnedViews: []) {
                        ForEach(viewModel.tasks) { task in
                            TaskRowView(
                                task: task,
                                taskCardHeight: 44,
                                hoveredTaskId: $hoveredTaskId,
                                viewModel: viewModel
                            )
                            .transition(.opacity)
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), 
                              value: viewModel.tasks)
                    .padding(.vertical, 8)
                }
                .modifier(StateDropAreaModifier(state: viewModel.currentViewState, viewModel: viewModel))
            }
        }
        .overlay {
            if showingCommandMenu {
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showingCommandMenu = false
                        }
                    
                    CommandMenu(isPresented: $showingCommandMenu, onSubmit: viewModel.addTask)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, 100)
                }
            }
        }
        .background(
            VisualEffectBlur(material: .contentBackground, blendingMode: .behindWindow)
        )
        .onAppear {
            _ = KeyboardShortcuts.setup {
                isInputFieldFocused = true
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: emptyStateIcon)
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.4))
            Text(emptyStateMessage)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateIcon: String {
        switch viewModel.currentViewState {
        case .active: return "square.and.pencil"
        case .completed: return "checkmark.circle"
        case .backlog: return "archivebox"
        }
    }
    
    private var emptyStateMessage: String {
        switch viewModel.currentViewState {
        case .active: return "Add your first task"
        case .completed: return "No completed tasks"
        case .backlog: return "Your backlog is empty"
        }
    }
}

struct SortToggle: View {
    @Binding var sortPreference: ImpulsoViewModel.SortPreference
    
    var body: some View {
        Toggle(isOn: Binding(
            get: { sortPreference == .priority },
            set: { sortPreference = $0 ? .priority : .manual }
        )) {
            Text("Sort by Priority")
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .toggleStyle(.checkbox)
        .padding(.horizontal, 8)
    }
}
