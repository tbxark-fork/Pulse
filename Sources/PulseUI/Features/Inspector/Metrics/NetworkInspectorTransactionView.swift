// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse

#warning("TODO: remove unused code")

#if os(iOS) || os(macOS) || os(tvOS)

// MARK: - View

struct NetworkInspectorTransactionView: View {
    @ObservedObject var viewModel: NetworkInspectorTransactionViewModel

    var body: some View {
        NetworkRequestStatusSectionView(viewModel: viewModel.statusSectionViewModel)
        viewModel.timingViewModel.map(TimingView.init)
        viewModel.transferSizeViewModel.map(NetworkInspectorTransferInfoView.init)

    }

//        ScrollView {
//            VStack {
//                if let timingViewModel = viewModel.timingViewModel {
//                    TimingView(viewModel: timingViewModel)
//                }
//                if let viewModel = viewModel.transferSizeViewModel {
//                    Section(header: LargeSectionHeader(title: "Transfer Size")) {
//                        NetworkInspectorTransferInfoView(viewModel: viewModel)
//                    }
//                }
//                Section(header: LargeSectionHeader(title: "Request")) {
//                    KeyValueGridView(items: [
//                        viewModel.requestSummary,
//                        viewModel.requestHeaders,
//                        viewModel.requestParameters
//                    ].compactMap { $0 })
//                }
//                Section(header: LargeSectionHeader(title: "Response")) {
//                    KeyValueGridView(items: [
//                        viewModel.responseSummary,
//                        viewModel.responseHeaders
//                    ])
//                }
//                if let details = viewModel.details {
//                    Section(header: LargeSectionHeader(title: "Details")) {
//                        KeyValueGridView(items: details.sections)
//                    }
//                }
//                Section(header: LargeSectionHeader(title: "Timing")) {
//                    KeyValueSectionView(viewModel: viewModel.timingSummary)
//                }
//            }
//            .padding(16)
//        }
//        .background(linkCount)
//    }

//    @ViewBuilder
//    private var linkCount: some View {
//        InvisibleNavigationLinks {
//            NavigationLink.programmatic(isActive: $viewModel.isOriginalRequestHeadersLinkActive, destination:  { NetworkDetailsView(title: "Request Headers", viewModel: viewModel.requestHeaders) })
//            NavigationLink.programmatic(isActive: $viewModel.isResponseHeadersLinkActive, destination:  { NetworkDetailsView(title: "Response Headers", viewModel: viewModel.responseHeaders) })
//        }
//    }
}

// MARK: - ViewModel

final class NetworkInspectorTransactionViewModel: ObservableObject {
    let statusSectionViewModel: NetworkRequestStatusSectionViewModel
    let timingViewModel: TimingViewModel?

    @Published var isOriginalRequestHeadersLinkActive = false
    @Published var isResponseHeadersLinkActive = false

    let details: NetworkMetricsDetailsViewModel?
    let transferSizeViewModel: NetworkInspectorTransferInfoViewModel?

    private let transaction: NetworkTransactionMetricsEntity

    init(transaction: NetworkTransactionMetricsEntity, task: NetworkTaskEntity) {
        self.statusSectionViewModel = NetworkRequestStatusSectionViewModel(transaction: transaction)
        self.details = NetworkMetricsDetailsViewModel(metrics: transaction)
        self.timingViewModel = TimingViewModel(transaction: transaction, task: task)
        if transaction.fetchType == .networkLoad {
            self.transferSizeViewModel = NetworkInspectorTransferInfoViewModel(transferSize: transaction.transferSize, isUpload: false)
        } else {
            self.transferSizeViewModel = nil
        }
        self.transaction = transaction
    }

    lazy var requestSummary = KeyValueSectionViewModel.makeSummary(for: transaction.request)

    lazy var requestParameters = KeyValueSectionViewModel.makeParameters(for: transaction.request)

    lazy var requestHeaders = KeyValueSectionViewModel.makeRequestHeaders(
        for: transaction.request.headers,
        action: { [unowned self] in self.isOriginalRequestHeadersLinkActive = true }
    )

    lazy var responseSummary: KeyValueSectionViewModel = {
        guard let response = transaction.response else {
            return KeyValueSectionViewModel(title: "Response", color: .indigo)
        }
        return KeyValueSectionViewModel.makeSummary(for: response)
    }()

    lazy var responseHeaders = KeyValueSectionViewModel.makeResponseHeaders(
        for: transaction.response?.headers ?? [:],
        action: { [unowned self] in self.isResponseHeadersLinkActive = true }
    )

    lazy var timingSummary = KeyValueSectionViewModel.makeTiming(for: transaction)
}

#if DEBUG
struct NetworkInspectorTransactionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                Section {
                    NetworkInspectorTransactionView(viewModel: mockModel)
                        .background(Color(UXColor.systemBackground))
                        .backport.navigationTitle("Network Load")
                }
            }
        }
        .previewDisplayName("Light")
        .environment(\.colorScheme, .light)
    }
}

private let mockModel = NetworkInspectorTransactionViewModel(transaction: mockTask.orderedTransactions.last!, task: mockTask)

private let mockTask = LoggerStore.preview.entity(for: .login)

#endif

#endif
