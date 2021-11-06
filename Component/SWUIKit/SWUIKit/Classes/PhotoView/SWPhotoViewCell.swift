//
//  VPPhotoViewCell.swift
//  VVPartner
//
//  Created by huang on 2019/11/13.
//  Copyright © 2019 vv. All rights reserved.
//

import UIKit

protocol SWPhotoViewCellDelegate: NSObjectProtocol {
    func deleteImage(_ cell: SWPhotoViewCell)
    func touchAddAction()
}

class SWPhotoViewCell: UICollectionViewCell {
    static let kReuseIdentifier = "SWPhotoViewCell"
    
    weak var delegate: SWPhotoViewCellDelegate?
    
    public var addPhotoType: SWPhotoViewAddPhotosType = .addDefault {
        didSet {
            switch addPhotoType {
            case .feedBack:
                feedBackCommonUI()
            case .addDefault:
                break
            }
        }
    }
    public var photoModel: SWPhotoViewModel? {
        didSet {
            updateCell()
        }
    }
        
    var photoImageView: UIImageView!
    var deleteButton: UIButton!
    var addButton: UIButton!
    var photoLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
        
    func feedBackCommonUI() {
        //         照相机
        addButton.setImage(loadImageNamed("sw_photo_view_camera_icon"), for: .normal)
        addButton.snp.remakeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        // delete
        deleteButton.setImage(loadImageNamed("sw_photo_view_feedback_delete"), for: .normal)
        deleteButton.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
        photoImageView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(0)
            make.trailing.equalToSuperview().offset(0)
        }
        // 拍照 label
        photoLabel.isHidden = false
        
        //cell带边框
        self.backgroundColor = UIColor(hex: 0xFafafa)
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(hex: 0xDFDFDF).cgColor
        
        self.layoutIfNeeded()
    }
    
    private func commonUI() {        
        photoImageView = UIImageView()
        photoImageView.layer.cornerRadius = 4
        photoImageView.layer.masksToBounds = true
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.backgroundColor = UIColor(hex: 0xF5F5F5)
        contentView.addSubview(photoImageView)
        
        deleteButton = UIButton()
        // vl_photoView_delete_icon 圆形叉号 vl_publish_cover_delete 方形不超出图片
        deleteButton.setImage(loadImageNamed("sw_photo_view_delete_icon"), for: .normal)
        deleteButton.addTarget(self, action: #selector(touchDeleteAction), for: .touchUpInside)
        contentView.addSubview(deleteButton)
        
        addButton = UIButton()
        // vl_photo_add 加号 vl_ordercomment_camere 照相机
        addButton.setImage(loadImageNamed("sw_photo_view_add_icon"), for: .normal)
        addButton.addTarget(self, action: #selector(touchAddPhotoAction), for: .touchUpInside)
        contentView.addSubview(addButton)
        
        photoImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(7)
            make.trailing.equalToSuperview().offset(-7)
        }
        
        deleteButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.size.equalTo(CGSize(width: 19, height: 19))
        }
        
        addButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(7)
            make.trailing.equalToSuperview().offset(-7)
        }
        
        // 拍照label
        photoLabel = UILabel()
        photoLabel.text = localizedString("sw_photo_view_uploadImage")
        photoLabel.textAlignment = .center
        photoLabel.font = .systemFont(ofSize: 12)
        photoLabel.textColor = UIColor(hex: 0x212121)
        contentView.addSubview(photoLabel)
        photoLabel.snp.makeConstraints({ (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(addButton.snp.bottom).offset(7)
        })
        photoLabel.isUserInteractionEnabled = true
        photoLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchAddPhotoAction)))
        photoLabel.isHidden = true
    }
    
    private func updateCell() {
         
        let placeholder = UIImage(named: "vl_reserveconfirm_img")
        
        if let imageUrl = self.photoModel?.photoUrl {
            self.photoImageView.loadWebImage(imageUrl,
                                             maxWidth: 500,
                                             completionHandler: { [weak self] (result) in
                switch result {
                case .success(let imageO):
                    if let image = imageO {
                        self?.photoImageView.image = image
                    }
                case .failure(_):
                    self?.photoImageView.image = placeholder
                }
            })
        }
        
        if self.photoModel?.isAddPhoto == true {
            self.deleteButton.isHidden = true
            self.photoImageView.isHidden = true
            self.addButton.isHidden = false
            self.photoLabel.isHidden = false
            self.layer.cornerRadius = 8
            self.layer.borderWidth = 0.5
            self.layer.borderColor = UIColor(hex: 0xDFDFDF).cgColor
        } else {
            self.deleteButton.isHidden = false
            self.photoImageView.isHidden = false
            self.addButton.isHidden = true
            self.photoLabel.isHidden = true
            self.layer.cornerRadius = 4//UI走查 展示图片时圆角变小
            self.layer.borderWidth = 0
            self.layer.borderColor = UIColor.clear.cgColor
        }
        
        if self.addPhotoType == .addDefault {
            self.layer.borderWidth = 0
            self.layer.borderColor = UIColor.clear.cgColor
        }
    }
   
    @objc private func touchPhotoItem() {
        
    }
    
    @objc private func touchDeleteAction() {
        self.delegate?.deleteImage(self)
    }
    
    @objc private func touchAddPhotoAction() {
        self.delegate?.touchAddAction()
    }
    
    //压缩尺寸
    func compressedSize(originData: Data,
                        originImage: UIImage ,
                        width: CGFloat?,
                        height: CGFloat?) -> UIImage {
        
        var resultImage: UIImage?
        /// 取大的倍数缩放
        var scale: CGFloat?
        if let width = width {
            scale = CGFloat(width) / originImage.size.width
        }
        if let height = height {
            let heightScale = CGFloat(height) / originImage.size.height
            scale = scale == nil ? heightScale : max(scale!, heightScale)
        }
        if scale != nil {
            resultImage = originImage.reSize(scale: scale!, originData: originData)
        } else {
            resultImage = originImage
        }
        return resultImage!
    }
}
