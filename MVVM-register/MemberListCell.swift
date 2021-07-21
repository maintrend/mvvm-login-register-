//
//  MemberListCell.swift
//  MVVM-register
//
//  Created by talgat on 6/19/21.
//

import UIKit
import RxSwift
import RxCocoa

class MemberListCell: UITableViewCell {

    var disposeBag = DisposeBag()
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func setData(_ member: Member) {
        loadMemberAvatar(url: member.avatar)
            .observe(on: MainScheduler.instance)
            .bind(to: avatarImgView.rx.image)       // bind : 단순히 onNext만 수행할 때
            .disposed(by: disposeBag)
        avatarImgView.image = nil
        nameLabel.text = member.name
        jobLabel.text = member.job
        ageLabel.text = "(\(member.age))"
    }
    
    // 이미지 불러오기
    func loadMemberAvatar(url: String) -> Observable<UIImage?> {
        
        return Observable.create { emitter in
            
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
                
                // 에러 발생시 종료
                if let err = error {
                    print(err.localizedDescription)
                    emitter.onError(err)
                    return
                }
                
                // data nil 처리
                guard let data = data, let image = UIImage(data: data) else {
                    emitter.onNext(nil)
                    emitter.onCompleted()
                    return
                }
                
                emitter.onNext(image)
                emitter.onCompleted()
                
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }

}
