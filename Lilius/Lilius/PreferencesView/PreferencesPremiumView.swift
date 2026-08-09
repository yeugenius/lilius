//
//  PreferencesPremiumView.swift
//  Lilius
//
//  Created by Satendra Singh on 24/11/24.
//

import SwiftUI
import StoreKit

struct PreferencesPremiumView: View {
    @ObservedObject private var viewModel = InAppPurchaseViewModel()
    
    private let price: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Spacer()
                        switch viewModel.inappViewState {
                        case .subscribed:
                            Text("You are a Premium member")
                        default:
                            Text("You are using free version of the app")
                        }
                        Spacer()
                    }
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Premium features:")
                                .bold()
                            Text("▶️ Shows Google calendar events")
                            Text("▶️ Shows Outlook calendar events")
                            Text("▶️ Other upcoming premium features")
                            Spacer()
                            switch viewModel.inappViewState {
                            case .unsubscribed:
                                buttonView
                            case .expired(let date):
                                if let dateStr = date?.expiryString {
                                    Text("Subscription expired on \(dateStr)")
                                        .foregroundColor(.red)
                                } else {
                                    Text("Subscription expired")
                                        .foregroundColor(.red)
                                }
                                
//                                Text("Subscription expired on \(date?.expiryString ?? "")")
//                                    .foregroundColor(.red)
                                buttonView
                            case .subscribed(plan: let plan, expiry: let expiry):
                                if let date = expiry {
                                    let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
                                    if viewModel.isTrialAvailable {
                                        Text("Your Trial will renew automatically after \(days) days")
                                    }
                                    Text("Your subscription will renew automatically after \(days) days")
                                        .foregroundColor(.green)

                                } else {
                                    Text("Active plan: \(plan), Expires: \(expiry?.expiryString ?? "")")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.leading, 56)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    Button("Restore") {
                        viewModel.restorePurchases()
                    }
                    .padding()
                }

            }
        }
    }
    
    private var buttonView: some View {
         VStack {
            switch viewModel.viewState {
            case .error(let error):
                    Text(error.description)
                    .padding()
                    .lineLimit(1)

                Button("Retry") {
                    viewModel.checkAndFetchProducts()
                }
                
            case .productInfoAvailable(let result):
                if let plan = result.first {
//                    Text("▶️ \(plan.localizedDescription)")
                    if (plan.introductoryPrice != nil) {
                        Text("🎉 30-Days Free Trial")
                                .bold()
                            Text("Enjoy free access. Cancel anytime before the trial ends.")
                                .padding(.horizontal)
                        Text("Then \(plan.priceLocale.currencySymbol ?? "$")\(plan.price) per \(plan.subscriptionPeriod?.unit.name ?? "month")")
                        Button("Start Free Trial") {
                            viewModel.purchaseMonthlyMembership()
                        }
                        .disabled(viewModel.viewState == .loading)
                    } else {
                        Button("Subscribe for \(plan.formattedPrice ?? "") \(plan.duration)") {
                            viewModel.purchaseMonthlyMembership()
                        }
                        .disabled(viewModel.viewState == .loading)

                    }
                }
            case .loading:
                CircularLoader()
            default:
                EmptyView()
                    .frame(width: 0, height: 0)
            }
        }
    }
}

#Preview {
    PreferencesPremiumView()
}

extension SKProduct.PeriodUnit {
    var name: String {
        switch self {
        case .month:
            return "month"
        case .year:
            return "year"
        case .week:
            return "week"
        case .day:
            return "day"
        @unknown default:
            return "month"
        }
    }
    
}
