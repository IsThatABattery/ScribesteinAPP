import SwiftUI

struct EventsView: View {
    @StateObject private var viewModel = EventsViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color.clear

                Group {
                    if viewModel.isLoading && viewModel.events.isEmpty {
                        VStack(spacing: SSpace.m.rawValue) {
                            ProgressView()
                                .tint(SColor.accent)
                            Text("Loading events...")
                                .font(.subheadline)
                                .foregroundStyle(SColor.textSecondary)
                        }
                    } else if let error = viewModel.errorMessage, viewModel.events.isEmpty {
                        VStack(spacing: SSpace.m.rawValue) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 40))
                                .foregroundStyle(SColor.textMuted)
                            Text("Unable to load events")
                                .font(.headline)
                                .foregroundStyle(SColor.text)
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(SColor.textSecondary)
                                .multilineTextAlignment(.center)
                            Button("Retry") {
                                viewModel.fetchEvents(forceRefresh: true)
                            }
                            .buttonStyle(SButtonSecondary())
                        }
                        .padding(SSpace.l.rawValue)
                    } else if viewModel.events.isEmpty {
                        VStack(spacing: SSpace.m.rawValue) {
                            Image(systemName: "calendar")
                                .font(.system(size: 40))
                                .foregroundStyle(SColor.textMuted)
                            Text("No upcoming events")
                                .font(.headline)
                                .foregroundStyle(SColor.text)
                            Text("Events from your chapter calendar will appear here.")
                                .font(.subheadline)
                                .foregroundStyle(SColor.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(SSpace.l.rawValue)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: SSpace.s.rawValue) {
                                ForEach(viewModel.events) { event in
                                    EventCard(event: event)
                                }
                            }
                            .padding(SSpace.m.rawValue)
                        }
                        .refreshable {
                            viewModel.fetchEvents(forceRefresh: true)
                        }
                    }
                }
            }
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchEvents()
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Event Card

struct EventCard: View {
    let event: CalendarEvent

    var body: some View {
        GlassCard {
            HStack(alignment: .top, spacing: SSpace.m.rawValue) {
                // Date badge
                VStack(spacing: 2) {
                    Text(event.formattedDayMonth.day)
                        .font(.title2.bold().monospacedDigit())
                        .foregroundStyle(event.isToday ? SColor.accent : SColor.text)
                    Text(event.formattedDayMonth.month)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(SColor.textSecondary)
                }
                .frame(width: 44)
                .padding(.vertical, SSpace.xs.rawValue)

                // Divider
                Rectangle()
                    .fill(SColor.glassBorder)
                    .frame(width: 1)
                    .padding(.vertical, SSpace.xxs.rawValue)

                // Content
                VStack(alignment: .leading, spacing: SSpace.xs.rawValue) {
                    if event.isToday {
                        Text("TODAY")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(SColor.accent)
                            .tracking(0.5)
                    } else if event.isTomorrow {
                        Text("TOMORROW")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(SColor.blue)
                            .tracking(0.5)
                    }

                    Text(event.summary)
                        .font(.headline)
                        .foregroundStyle(SColor.text)
                        .fixedSize(horizontal: false, vertical: true)

                    if let time = event.formattedTime {
                        Label(time, systemImage: "clock")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(SColor.textSecondary)
                    }

                    if let location = event.location, !location.isEmpty {
                        Label(location, systemImage: "mappin.and.ellipse")
                            .font(.caption)
                            .foregroundStyle(SColor.textSecondary)
                            .lineLimit(1)
                    }

                    if let description = event.description, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(SColor.textMuted)
                            .lineLimit(2)
                            .padding(.top, 2)
                    }
                }

                Spacer(minLength: 0)
            }
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView()
    }
}
