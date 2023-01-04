// The MIT License (MIT)
//
// Copyright (c) 2020–2023 Alexander Grebenyuk (github.com/kean).

import SwiftUI
import Pulse

struct NetworkMenuCell: View {
    let icon: String
    let tintColor: Color
    let title: String
    var details: String = ""

    var body: some View {
#if os(watchOS)
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                Text(details).foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: icon)
                .foregroundColor(tintColor)
                .font(.system(size: 18))
                .frame(width: 18, alignment: .trailing)
        }
#elseif os(tvOS)
        HStack {
            Text(title)
            Spacer()
            Text(details).foregroundColor(.secondary)
        }
#else
        HStack {
            Image(systemName: icon)
                .foregroundColor(tintColor)
                .font(.system(size: 20))
                .frame(width: 27, alignment: .leading)
            Text(title)
            Spacer()
            Text(details).foregroundColor(.secondary)
        }
#endif
    }
}
