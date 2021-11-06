//
//  VPPhotoView.swift
//  VVPartner
//
//  Created by Allan on 2019/11/7.
//  Copyright © 2019 vv. All rights reserved.
//

import UIKit
import SWBusinessKit
import Photos
import Kingfisher

public enum SWPhotoViewAddPhotosType {
    case addDefault // 默认
    case feedBack // 点赞
}

public protocol SWPhotoViewDelegate: class {
    func didFinishPick(_ view: SWPhotoView)
    func willRemoveImage(_ view: SWPhotoView, index: Int)
    func didRemoveImage(_ view: SWPhotoView, model: SWPhotoViewModel)
    func shouldConfirmDeleteImage(_ view: SWPhotoView, model: SWPhotoViewModel) -> Bool
    func didClickItem(_ view: SWPhotoView, atIndexPath: IndexPath)
}

extension SWPhotoViewDelegate {
    
    public func shouldConfirmDeleteImage(_ view: SWPhotoView, model: SWPhotoViewModel) -> Bool {
        return false
    }
    
    public func didClickItem(_ view: SWPhotoView, atIndexPath: IndexPath) {
        
    }
    
    public func willRemoveImage(_ view: SWPhotoView, index: Int) {
        
    }
}

public class SWPhotoView: UIView {
    public weak var delegate: SWPhotoViewDelegate?
    public var addPhotoType: SWPhotoViewAddPhotosType = .addDefault {
        didSet {
            switch addPhotoType {
            case .feedBack:
                photoCollectionView.reloadData()
                compressionQuality = 0.5
            case .addDefault:
                break
            }
        }
    }
    /// item列间距
    public var innerColumnMargin: CGFloat = 16.0
    /// item行间距
    public var innerLineMargin: CGFloat = 16.0
    /// 最多图片数
    public var maxPhotos: Int = 6
    /// 编辑模式（显示上传按钮+图片右上角删除按钮）
    public var editMode: Bool = true {
        didSet {
            if editMode {
                showDeleteButton = true
                showAddPhoto = true
            } else {
                showDeleteButton = false
                showAddPhoto = false
            }
        }
    }
    /// 是否显示删除按钮
    public var showDeleteButton: Bool = true
    /// 是否显示添加图片按钮
    public var showAddPhoto: Bool = true
    /// photoCell size
    public var photoCellSize: CGSize = CGSize(width: 100.0, height: 100.0)
    /// 拍照时图片压缩率
    public var compressionQuality: CGFloat = 1.0
    /// section边距
    public var sectionInset: UIEdgeInsets?
    /// 调用系统相机拍照控制器
    public lazy var imagePicker: UIImagePickerController = {
        let picker  = UIImagePickerController()
        return picker
    }()
    
    public var models: [SWPhotoViewModel] {
        set {
            photosDataSource = newValue
        }
        get {
            return photosDataSource.filter { $0.isAddPhoto == false }
        }
    }
    
    /// photo数据源
    public var photosDataSource: [SWPhotoViewModel] = [] {
        didSet {
            self.reloadPhoto()
        }
    }
    
    public func reloadPhoto() {
        
        if photosDataSource.count >= (self.maxPhotos + 1) {
            photosDataSource.removeLast()
        }
        
        if showAddPhoto {
            if photosDataSource.count < maxPhotos,
                photosDataSource.last == nil || photosDataSource.last!.isAddPhoto == false {
                let model = SWPhotoViewModel()
                model.photoUrl = nil
                model.isAddPhoto = true
                self.photosDataSource.append(model)
            }
        }
        
        if self.addPhotoType == .addDefault {
            photoCollectionView.layoutIfNeeded()
            photoCollectionView.snp.updateConstraints { (make) in
                make.height.equalTo(photoCollectionView.contentSize.height)
            }
        }
        
        self.photoCollectionView.reloadData()
    }
    
    public var photoCollectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        photoCollectionView = makeCommon(direction: .vertical)
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.register(SWPhotoViewCell.self, forCellWithReuseIdentifier: SWPhotoViewCell.kReuseIdentifier)
        addSubview(photoCollectionView)
        
        photoCollectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(0)
        }
    }
    
    private func makeCommon(direction: UICollectionView.ScrollDirection) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = direction
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.isScrollEnabled = false
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = false
        }
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        return collectionView
    }

}

extension SWPhotoView: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let type = info[UIImagePickerController.InfoKey.mediaType] as? String, type == "public.image" else {
            return
        }
        
        guard let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        if let data = img.jpegData(compressionQuality: compressionQuality) {
            insertImage(data, url: UUID().uuidString.md5())
            self.reloadPhoto()
            self.delegate?.didFinishPick(self)
            picker.dismiss(animated: true)
        }
        
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}

extension SWPhotoView: SWPhotoViewCellDelegate {
    func touchAddAction() {
        let options = [
            localizedString("sw_photo_view_option_camera"),
            localizedString("sw_photo_view_option_photo")
        ]
        
        SWAlert.showActionSheet(title: nil, message: nil, cancel: localizedString("sw_photo_view_cancel"), others: options) { [weak self] (index) in
            if index == 0 {
                self?.showCameraPickerView()
            } else if index == 1 {
                self?.showImagePickerView()
            }
        }
    }
    
    func deleteImage(_ cell: SWPhotoViewCell) {
        
        let indexPath = self.photoCollectionView.indexPath(for: cell)! as NSIndexPath
        let model = self.photosDataSource[indexPath.row]
        
        self.delegate?.willRemoveImage(self, index: indexPath.row)
        
        let deleteClosure = { [unowned self] in
            self.photosDataSource.remove(at: indexPath.row)
            self.reloadPhoto()
            self.delegate?.didRemoveImage(self, model: model)
        }
        
        if let shouldRemove = self.delegate?.shouldConfirmDeleteImage(self, model: model), shouldRemove {
            SWAlert.showMessageAlert(title: nil, message: localizedString("sw_photo_view_delete"), confirm: localizedString( "sw_photo_view_sure"), cancel: localizedString("sw_photo_view_cancel")) { (confirm) in
                if confirm {
                    deleteClosure()
                }
            }
        } else {
            deleteClosure()
        }
    }
}

extension SWPhotoView {
    private func showCameraPickerView() {
        guard maxPhotos - self.photosDataSource.count + 1 > 0 else {
            return
        }
        // 相机权限
        SWCameraAlbumPermission.cameraPermission(authorizedClosure: { [weak self] in
            self?.imagePicker.delegate = self
            self?.imagePicker.sourceType = .camera
            if self?.imagePicker != nil {
                SWRouter.currentViewController().present(self!.imagePicker, animated: true, completion: nil)
            }
        }) {
            SWAlert.showMessageAlert(title: nil, message: localizedString("sw_camera_needs_to_obtain_permissions"), confirm: localizedString("sw_edit_profile_OK"), confirmColor: UIColor(hex: 0x333333), cancel: nil, handler: { (isOk) in
                if let settingUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingUrl) {
                    UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
                }
            })
        }
    }
    
    /// 相册权限
   
    private func photoAlbumPermissions(authorizedBlock: (() -> Void)?, deniedBlock: (() -> Void)?) {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        
        /// .notDetermined  .authorized  .restricted  .denied
        if authStatus == .notDetermined {
            /// 第一次触发授权 alert
            PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) -> Void in
                self.photoAlbumPermissions(authorizedBlock: authorizedBlock, deniedBlock: deniedBlock)
            }
        } else if authStatus == .authorized {
            guard let authorizedBlock = authorizedBlock else { return }
            authorizedBlock()
        } else {
            guard let deniedBlock = deniedBlock else { return }
            deniedBlock()
        }
    }
    
    private func showImagePickerView() {
        guard maxPhotos - self.photosDataSource.count + 1 > 0 else {
            return
        }
        self.photoAlbumPermissions(authorizedBlock: {
            
            let imagePicker = SWImagePickerController()
            imagePicker.modalPresentationStyle = .fullScreen
            imagePicker.settings.selection.max = self.maxPhotos - self.models.count
            let options = imagePicker.settings.fetch.album.options
            imagePicker.settings.fetch.album.fetchResults = [
                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: options),
                PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: options)
            ]
            SWRouter.currentViewController().presentImagePicker(imagePicker, animated: true, select: { (asset) in
                
            }, deselect: { (asset) in
                
            }, cancel: { (assets) in
                
            }, lint: { (count) in
                //let msg = localizedString("sw_photo_view_photos_max")
                ///SWToast.showText(message: msg)
                print("TODO: FIX")
                
            }, finish: { [weak self] (assets) in
                // 获取到照片
                self?.finishImagePick(assets)
                
                }, completion: {
                    
            })
            
        }) {
            print("没有权限打开相册")
            DispatchQueue.main.async {
               ///SWToast.showText(message: localizedString("sw_photo_album_permission"))
                print("TODO: FIX")
            }
        }
    }
    
    private func finishImagePick(_ assets: [PHAsset]) {
        print("TODO: FIX")
        //SWToast.showAnimationActivity()
        
        let group = DispatchGroup()
        let serialQueue = DispatchQueue(label: "com.photoView.serialqueue")
        
        for asset in assets {
            group.enter()
            serialQueue.async {
                let imageOption = PHImageRequestOptions()
                imageOption.isSynchronous = true
                imageOption.isNetworkAccessAllowed = true
                imageOption.progressHandler = { (progress, error, stop, info) in
                    
                }
                
                PHImageManager.default().requestImageData(for: asset, options: imageOption) { (imageData, urlPath, orientation, arr)  in
                    if let imageData = imageData {
                        let tempImage = UIImage(data: imageData)
                        if let smallData = tempImage?.jpegData(compressionQuality: 0.3) {
                            DispatchQueue.main.async { [weak self] in
                                self?.insertImage(smallData, url: asset.localIdentifier.md5())
                            }
                        }
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main) { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                print("TODO: FIX")
                //SWToast.hideAll()
                self.reloadPhoto()
                self.delegate?.didFinishPick(self)
            }
        }
    }
    
    private func insertImage(_ imageData: Data, url: String) {
        let key = "local:\(url)"
        let model = SWPhotoViewModel()
        model.photoUrl = key
        model.isAddPhoto = false
        SWPhotoCache.saveImage(data: imageData, forKey: key)
        
        if let last = self.photosDataSource.last, last.isAddPhoto {
            self.photosDataSource.insert(model, at: self.photosDataSource.count - 1)
        } else {
            self.photosDataSource.append(model)
        }
    }
}

extension SWPhotoView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.photosDataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SWPhotoViewCell.kReuseIdentifier, for: indexPath) as! SWPhotoViewCell
        cell.addPhotoType = self.addPhotoType
        let model = self.photosDataSource[indexPath.row]
        cell.photoModel = model
        cell.delegate = self
        if !model.isAddPhoto {
            cell.deleteButton.isHidden = !showDeleteButton
        }

        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.didClickItem(self, atIndexPath: indexPath)
    }
}

extension SWPhotoView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.photoCellSize
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return self.sectionInset ?? .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.innerLineMargin
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return self.innerColumnMargin
    }
}
