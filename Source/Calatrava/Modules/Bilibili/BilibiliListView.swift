//
//  BilibiliListView.swift
//  Calatrava
//
//  Created by 郑宇琦 on 2018/5/20.
//

import Foundation
import Pjango

class BilibiliListView: PCListView {
    
    override var templateName: String? {
        return "bilibili_list.html"
    }
    
    var displayFeed: [BilibiliFeedModel]?
    
    override var listObjectSets: [String : [PCModel]]? {
        defer {
            displayFeed = nil
        }
        var list = BilibiliListModel.queryObjects() as? [BilibiliListModel]
        list?.sort(by: { $0.updateDate > $1.updateDate })
        return [
            "_pjango_param_table_bilibili_feed": displayFeed ?? [],
            "_pjango_param_table_bilibili_list": list ?? []
        ]
    }
    
    override func listUserField(inList list: String, forModel model: PCModel) -> PCViewParam? {
        if list == "_pjango_param_table_bilibili_feed" {
            guard let feed = model as? BilibiliFeedModel else {
                return nil
            }
            var coverName = ""
            if feed.cover.strValue != "null" {
                coverName = feed.cover.strValue
            } else {
                coverName = "\(feed.blid.intValue)_cover.jpg"
            }
            let coverUrl = "\(WEBSITE_HOST)/img/bilibili/\(coverName)"
            let fromList = (BilibiliListModel.queryObjects() as? [BilibiliListModel])?.first(where: { $0.blid.intValue == feed.blid.intValue })
            let listName = fromList?.name.strValue
            return [
                "_pjango_param_table_BilibiliFeed_COVER_URL": coverUrl,
                "_pjango_param_table_BilibiliFeed_LIST_NAME": listName ?? "null"
            ]
        } else if list == "_pjango_param_table_bilibili_list" {
            guard let list = model as? BilibiliListModel else {
                return nil
            }
            let coverUrl = "\(WEBSITE_HOST)/img/bilibili/\(list.blid.intValue)_cover.jpg"
            var buttonText = ""
            var buttonId = ""
            if let id = currentRequest?.getUrlParam(key: "id"), id == "\(list.blid.intValue)" {
                buttonText = "取消选择"
                buttonId = ""
            } else {
                buttonText = "选择播单"
                buttonId = "\(list.blid.intValue)"
            }
            let videos = (BilibiliFeedModel.queryObjects() as? [BilibiliFeedModel])?.filter { $0.blid.intValue == list.blid.intValue } ?? []
            let videoCount = videos.count
            let lastUpdate = videos.last?.date.strValue ?? "1970-01-01 08:00"
            return [
                "_pjango_param_table_BilibiliList_COVER_URL": coverUrl,
                "_pjango_param_table_BilibiliList_VIDEO_COUNT": "\(videoCount)",
                "_pjango_param_table_BilibiliList_LIST_BUTTON_TEXT": buttonText,
                "_pjango_param_table_BilibiliList_LIST_BUTTON_ID": buttonId,
                "_pjango_param_table_BilibiliList_UPDATE_DATE": lastUpdate,
            ]
        } else {
            return nil
        }
    }
    
    override var viewParam: PCViewParam? {
        guard let request = currentRequest else {
            return nil
        }
        guard var feeds = BilibiliFeedModel.queryObjects() as? [BilibiliFeedModel] else {
            return nil
        }
        var id = ""
        if let idParam = request.getUrlParam(key: "id"), idParam != "" {
            feeds = feeds.filter { "\($0.blid.intValue)" == idParam }
            id = idParam
        }
        // 相同日期时候需要按照id逆序，所以先排序后逆转
        feeds = feeds.sorted { $0.date.strValue < $1.date.strValue }
        feeds.reverse()
        var page = 1
        if let pageParam = Int(request.getUrlParam(key: "page") ?? ""), pageParam > 0 {
            page = pageParam
        }
        let eachPageFeedCount = 5
        let begin = eachPageFeedCount * (page - 1)
        let end = eachPageFeedCount * page - 1
        var bilibiliFeed = [BilibiliFeedModel].init()
        if (begin < feeds.count) {
            let trueEnd = min(feeds.count - 1, end)
            bilibiliFeed = Array(feeds[begin..<(trueEnd + 1)])
        }
        displayFeed = bilibiliFeed
        
        let titleMessage = ConfigModel.getValueForKey(.titleMessage) ?? "null"
        let bilibiliName = ConfigModel.getValueForKey(.bilibiliName) ?? "null"
        let bilibiliMessage = ConfigModel.getValueForKey(.bilibiliMessage) ?? "null"

        EventHooks.hookBilibili(req: request)

        return [
            "_pjango_template_navigation_bar": NavigationBarView.html,
            "_pjango_template_footer_bar": FooterBarView.html,
            "_pjango_param_title_message": titleMessage,
            "_pjango_url_host": WEBSITE_HOST,

            "_pjango_param_param_id": id,
            "_pjango_param_name": bilibiliName,
            "_pjango_param_message": bilibiliMessage,
            "_pjango_param_param_page": page,
            "_pjango_param_param_page_total": max(0, feeds.count - 1) / eachPageFeedCount + 1,
            "_pjango_param_param_total_count": feeds.count,
        ]
    }
    
    
}
