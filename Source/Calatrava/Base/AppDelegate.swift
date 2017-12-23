//
//  AppDelegate.swift
//  Calatrava
//
//  Created by 郑宇琦 on 2017/6/24.
//  Copyright © 2017年 郑宇琦. All rights reserved.
//

import Foundation
import PerfectHTTP
import Pjango
import Pjango_MySQL


class AppDelegate: PjangoDelegate {
    
    func setSettings() {
        
        // Pjango
        
        #if os(macOS)
            PJANGO_WORKSPACE_PATH = "/Users/Enum/Developer/macOS/Calatrava/Workspace"
        #else
            PJANGO_WORKSPACE_PATH = "/home/uftp/Calatrava-Blog/Workspace"
        #endif
        
        
        PJANGO_LOG_DEBUG = false
        
        PJANGO_SERVER_PORT = 80
        
        PJANGO_LOG_PATH = "runtime/calatrava.log"
        
        // Django
        
        PJANGO_BASE_DIR = ""
        
        PJANGO_TEMPLATES_DIR = "templates"
        
        PJANGO_STATIC_URL = "static"
        
    }
    
    func setUrls() -> [String: [PCUrlConfig]]? {
        
        return [
            
            PJANGO_HOST_DEFAULT: [
                pjangoUrl("", name: "index", handle: IndexView.asHandle()),
                pjangoUrl("404", name: "error.404", handle: ErrorNotFoundView.asHandle()),
            ],
            
            WEBSITE_HOST: [
                pjangoUrl("", name: "index", handle: IndexView.asHandle()),
                pjangoUrl("about", name: "about", handle: AboutView.asHandle()),
                
                pjangoUrl("api/message", name: "api.message", handle: messageHandle),
                
                //Old
                pjangoUrl("post", name: "old.posts.1", handle: postsOldHandle),
                pjangoUrl("posts", name: "old.posts.2", handle: postsOldHandle),
                pjangoUrl("playground", name: "old.playground", handle: ErrorNotSupportView.asHandle()),
            ],
            
            "posts.\(WEBSITE_HOST)": [
                pjangoUrl("list", name: "list", handle: PostsListView.asHandle()),
                pjangoUrl("posts/{pid}", name: "posts", handle: PostsView.asHandle()),
                pjangoUrl("search", name: "search", handle: PostsSearchView.asHandle()),
                
                pjangoUrl("api/love", name: "api.love", handle: postsLoveHandle),
                pjangoUrl("api/comment", name: "api.comment", handle: postsCommentHandle),
                
            ],
            
            "project.\(WEBSITE_HOST)": [
                pjangoUrl("list", name: "list", handle: ProjectListView.asHandle()),
            ],
            
            "playground.\(WEBSITE_HOST)": [
                pjangoUrl("swift", name: "swift", handle: ErrorNotSupportView.asHandle()),
                
            ],
            
        ]
    }
    
    func setDB() -> PCDataBase? {
        return MySQLDataBase.init(param: [
            "SCHEMA": "Pjango_calatrava",
            "USER": "",
            "PASSWORD": "",
            "HOST": "127.0.0.1",
            "PORT": UInt16(3306),
            ])
        
//        return PCFileDBDataBase.init(param: [
//                "SCHEMA": "default",
//                "PATH": "\(PJANGO_WORKSPACE_PATH)/filedb"
//            ])
    }
    
    func registerModels() -> [PCModel]? {
        return [
            PostsModel.meta,
            PostsTagModel.meta,
            PostsCommentModel.meta,
            PostsHistoryModel.meta,
            ProjectModel.meta,
            
            ConfigModel.meta,
            MessageModel.meta,
            
            VisitStatisticsModel.meta,
        ]
    }

    func registerPlugins() -> [PCPlugin]? {
        return [
            PCLogFilterPlugin.meta,
            NotFoundFilterPlugin.meta,
            DailyCleanPlugin.meta,
        ]
    }
    
}