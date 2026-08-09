//
//  CalendarEventListView.swift
//  Lilius
//
//  Created by Satendra Singh on 17/11/24.
//

import SwiftUI

struct CalendarEventListView: View {
    @EnvironmentObject var eventListModel: CalendarEventListViewModel
    
    var dayModel: CalendarDayModel
    private var allDayEvents: [CalendarDayEventModel] { dayModel.events.filter(\.isAllDay) }
    private var partialDayEvents: [CalendarDayEventModel] { dayModel.events.filter{$0.isAllDay == false} }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 23)
            CalendarEventHeaderView(eventTitle: eventListModel.eventDetailsTitle(forDay: dayModel.dateComponent))
            //            VDivider()
            
            Divider()
            if allDayEvents.isEmpty && partialDayEvents.isEmpty {
                Spacer()
                Text("Available events for selected day will be displayed here.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                        ForEach(allDayEvents) { event in
                            HStack {
                                Group {
                                    if let url = event.url {
                                        callButtonView(url, title: "All-Day")
                                    } else {
                                        Text("All-Day")
                                    }
                                }
                                .frame(width: 100)
                                Text(event.event?.title ?? "")
                            }
                            Spacer()
                                .frame(height: 20)
                        }
                        if !allDayEvents.isEmpty && !partialDayEvents.isEmpty {
                            VDivider()
                                .padding(0)
                        }
                        ForEach(partialDayEvents) { event in
                            HStack {
                                Group {
                                    if let url = event.url {
                                        callButtonView(url, title: event.event?.startD?.timeString ?? "")
                                    } else {
                                        Text(event.event?.startD?.timeString ?? "")
                                    }
                                }
                                .frame(width: 100)
                                Text(event.event?.title ?? "")
                            }
                            Spacer()
                                .frame(height: 20)
                        }
                        Spacer()
                    }
                }
                .padding(0)
            }
        }
    }
    
    func callButtonView(_ url: URL, title: String) -> some View {
        Button(action: {
            NSWorkspace.shared.open(url)
        }) {
            HStack(spacing: 4) {
                Image(systemName: "video.fill")
                    .resizable()
                    .frame(width: 8, height: 8)

                Text(title)
                    .font(.system(size: 10)) // Optional: fine-tune text size
            }
            .padding(.horizontal, 6)
            .frame(height: 20)
            .background(RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray, lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle()) // Avoids default blue highlight on macOS
    }
}

#Preview {
    CalendarEventListView(dayModel: .init())
}

struct VDivider: View {
    let color: Color = .gray
    let width: CGFloat = 2
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: width)
            .edgesIgnoringSafeArea(.horizontal)
    }
}

struct HDivider: View {
    let color: Color = .gray
    let height: CGFloat = 2
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: height)
            .edgesIgnoringSafeArea(.vertical)
    }
}

struct EventDetails: View {
    var body: some View {
        Spacer()
    }
}

struct EventHeaderTitleView: View {
    let title: String
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: 10)
            Text(title)
                .frame(height: 10)
                .padding(.horizontal, 20)
            VDivider()
                .padding(0)
        }
    }
}
