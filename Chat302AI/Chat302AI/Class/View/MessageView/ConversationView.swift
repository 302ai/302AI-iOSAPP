//
//  ConversationView.swift
//  GPTalks
//
//  Created by Zabir Raihan on 19/12/2023.
//

import SwiftUI

struct ConversationView: View {
    var session: DialogueSession
    var conversation: Conversation
    
    var isQuick: Bool = false
    @FocusState var focused: Bool
    @Binding var showFeedback: Bool
    
    var scrollToMessageTop: () -> Void = {}

    var body: some View {
        VStack { // TODO dont use vstack
            Group {
                switch conversation.role {
                case .user:
                    UserMessageView2(conversation: conversation, session: session,focused:_focused) {
                            scrollToMessageTop()
                        }
                    
                   // VStack{}
                case .assistant:
                    AssistantMessageView2(conversation: conversation, session: session, isQuick: isQuick,focused:_focused, showFeedback:$showFeedback)
                    
//                    if !conversation.reasoning?.isEmpty{
//                        AssistantMessageView(conversation: conversation, session: session, isQuick: isQuick)
//                    }
                    
                    
                case .system:
                    // never coming here
                    CustomText(conversation.content)
                }
            }
            .opacity(0.9)

            if session.conversations.firstIndex(of: conversation) == session.resetMarker {
                ContextResetDivider(session: session)
                    .padding()
            }
        }
    }
}
