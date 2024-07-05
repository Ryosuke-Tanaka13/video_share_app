
# ER Diagram from Models

## ER Diagram(主にリレーション)
```mermaid
erDiagram
  applicationrecord {
  }
  comment {
  }
  folder {
  }
  organization {
  }
  organizationviewer {
  }
  reply {
  }
  systemadmin {
  }
  user {
  }
  video {
  }
  videofolder {
  }
  viewer {
  }
  comment ||--o{ system_admin : "system_admin_id"
  comment ||--o{ user : "user_id"
  comment ||--o{ viewer : "viewer_id"
  comment ||--o{ organization : "organization_id"
  comment ||--o{ video : "video_id"
  replies ||--o{ comment : "comment_id"
  folder ||--o{ organization : "organization_id"
  video_folders ||--o{ folder : "folder_id"
  videos ||--o{ folder : "folder_id"
  users ||--o{ organization : "organization_id"
  organization_viewers ||--o{ organization : "organization_id"
  viewers ||--o{ organization : "organization_id"
  folders ||--o{ organization : "organization_id"
  videos ||--o{ organization : "organization_id"
  comments ||--o{ organization : "organization_id"
  replies ||--o{ organization : "organization_id"
  organizationviewer ||--o{ organization : "organization_id"
  organizationviewer ||--o{ viewer : "viewer_id"
  reply ||--o{ organization : "organization_id"
  reply ||--o{ system_admin : "system_admin_id"
  reply ||--o{ user : "user_id"
  reply ||--o{ viewer : "viewer_id"
  reply ||--o{ comment : "comment_id"
  comments ||--o{ systemadmin : "systemadmin_id"
  replies ||--o{ systemadmin : "systemadmin_id"
  user ||--o{ organization : "organization_id"
  videos ||--o{ user : "user_id"
  comments ||--o{ user : "user_id"
  replies ||--o{ user : "user_id"
  video ||--o{ organization : "organization_id"
  video ||--o{ user : "user_id"
  comments ||--o{ video : "video_id"
  video_folders ||--o{ video : "video_id"
  folders ||--o{ video : "video_id"
  videofolder ||--o{ video : "video_id"
  videofolder ||--o{ folder : "folder_id"
  organization_viewers ||--o{ viewer : "viewer_id"
  organizations ||--o{ viewer : "viewer_id"
  comments ||--o{ viewer : "viewer_id"
  replies ||--o{ viewer : "viewer_id"
```

