//
//  DetailViewController.swift
//  MVVM-register
//
//  Created by talgat on 6/19/21.
//

import UIKit
import RxSwift
import RxCocoa

class DetailViewController: UIViewController {

    var disposeBag = DisposeBag()
    var member: Member?
    
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let member = member {
            setData(member)
        }
        // Do any additional setup after loading the view.
    }
    
    func setData(_ member: Member) {
        loadMemberAvatar(url: member.avatar)
            .observe(on: MainScheduler.instance)
            .bind(to: avatarImgView.rx.image)
            .disposed(by: disposeBag)
        idLabel.text = " # \(member.id)"
        avatarImgView.image = nil
        nameLabel.text = member.name
        jobLabel.text = member.job
        ageLabel.text = "(\(member.age))"
    }
    
    func loadMemberAvatar(url: String) -> Observable<UIImage?> {
        
        return Observable.create{ emitter in
            
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
                
                if let err = error {
                    emitter.onError(err)
                    return
                }
                
               
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
