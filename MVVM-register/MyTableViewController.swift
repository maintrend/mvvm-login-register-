//
//  MyTableViewController.swift
//  MVVM-register
//
//  Created by talgat on 6/19/21.
//

import UIKit
import RxSwift

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"
class MyTableViewController: UITableViewController {

   
    var disposeBag = DisposeBag()
    var memberList: [Member] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMemberList()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { members in
                print(members)
                self.memberList = members
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    func loadMemberList() -> Observable<[Member]> {
        
        return Observable.create { emitter in
            
            let task = URLSession.shared.dataTask(with: URL(string: MEMBER_LIST_URL)!) { (data, response, error) in
                
                if let err = error {
                    print(err.localizedDescription)
                    emitter.onError(err)
                    return
                }
                
               
    //            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
    //                return
    //            }
                
            
                guard let data = data, let json = try? JSONDecoder().decode([Member].self, from: data) else {
                    emitter.onCompleted()
                    return
                }
                
               
                emitter.onNext(json)
                emitter.onCompleted()
    //            print(json)
                
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goDetailSegue",
           let detailVC = segue.destination as? DetailViewController,
           let parmeter = sender as? Member {
            
            detailVC.member = parmeter
        }
    }
    // MARK: - Table view data source


}


extension MyTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = memberList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberListCell") as! MemberListCell
        cell.setData(item)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let member = memberList[indexPath.row]
        performSegue(withIdentifier: "goDetailSegue", sender: member)
    }
    
    
}
