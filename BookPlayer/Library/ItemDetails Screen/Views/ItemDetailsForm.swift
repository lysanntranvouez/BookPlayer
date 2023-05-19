//
//  ItemDetailsForm.swift
//  BookPlayer
//
//  Created by gianni.carlo on 18/12/22.
//  Copyright © 2022 Tortuga Power. All rights reserved.
//

import BookPlayerKit
import SwiftUI
import PhotosUI

struct ItemDetailsForm: View {
  /// View model for the form
  @ObservedObject var viewModel: ItemDetailsFormViewModel
  /// Theme view model to update colors
  @StateObject var themeViewModel = ThemeViewModel()
  /// Flag to show action sheet for the artwork
  @State private var showingArtworkOptions = false
  /// Flag to show the ImagePicker
  @State private var showingImagePicker = false
  /// Flag to show the empty pasteboard alert
  @State private var showingEmptyPasteboardAlert = false

  var body: some View {
    Form {
      Section(header: Text("details_title".localized)
        .foregroundColor(themeViewModel.secondaryColor)
      ) {
        ClearableTextField("item_title_placeholder".localized, text: $viewModel.title)
        if viewModel.showAuthor {
          ClearableTextField("item_author_placeholder".localized, text: $viewModel.author)
        }
      }
      .listRowBackground(themeViewModel.secondarySystemBackgroundColor)

      ItemDetailsArtworkSectionView(image: $viewModel.selectedImage) {
        showingArtworkOptions = true
      }
      .listRowBackground(themeViewModel.secondarySystemBackgroundColor)
    }
    .onChange(of: viewModel.selectedImage, perform: { _ in
      viewModel.artworkIsUpdated = true
    })
    .actionSheet(isPresented: $showingArtworkOptions) {
      ActionSheet(
        title: Text("artwork_options_title".localized),
        buttons: [
          .default(Text("artwork_photolibrary_title".localized)) {
            showingImagePicker = true
          },
          .default(Text("artwork_clipboard_title".localized)) {
            if let image = UIPasteboard.general.image {
              viewModel.selectedImage = image
            } else {
              showingEmptyPasteboardAlert = true
            }
          },
          .default(Text("artwork_reset_title".localized)) {
            viewModel.resetArtwork()
          },
          .cancel(),
        ]
      )
    }
    .sheet(isPresented: $showingImagePicker) {
      ImagePicker(image: $viewModel.selectedImage)
    }
    .alert(isPresented: $showingEmptyPasteboardAlert) {
      Alert(
        title: Text("artwork_clipboard_empty_title".localized),
        dismissButton: .default(Text("ok_button".localized))
      )
    }
  }
}

struct ItemDetailsForm_Previews: PreviewProvider {
  static var previews: some View {
    ItemDetailsForm(
      viewModel: ItemDetailsFormViewModel(
        item: SimpleLibraryItem(
          title: "title",
          details: "details",
          speed: 1,
          currentTime: 0,
          duration: 100,
          percentCompleted: 1,
          isFinished: false,
          relativePath: "",
          remoteURL: nil,
          artworkURL: nil,
          orderRank: 0,
          parentFolder: nil,
          originalFileName: "",
          lastPlayDate: nil,
          type: .book
        )
      )
    )
  }
}
