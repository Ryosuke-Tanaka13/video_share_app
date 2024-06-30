```mermaid
 erDiagram
  system_admin ||--o{ comment : "comment_id"
  user ||--o{ comment : "comment_id"
  viewer ||--o{ comment : "comment_id"
  organization ||--o{ comment : "comment_id"
  video ||--o{ comment : "comment_id"
  replies ||--o{ comment : "replies_id"
  organization ||--o{ folder : "folder_id"
  video_folders ||--o{ folder : "video_folders_id"
  videos ||--o{ folder : "videos_id"
  users ||--o{ organization : "users_id"
  organization_viewers ||--o{ organization : "organization_viewers_id"
  viewers ||--o{ organization : "viewers_id"
  folders ||--o{ organization : "folders_id"
  videos ||--o{ organization : "videos_id"
  comments ||--o{ organization : "comments_id"
  replies ||--o{ organization : "replies_id"
  organization ||--o{ organizationviewer : "organizationviewer_id"
  viewer ||--o{ organizationviewer : "organizationviewer_id"
  organization ||--o{ reply : "reply_id"
  system_admin ||--o{ reply : "reply_id"
  user ||--o{ reply : "reply_id"
  viewer ||--o{ reply : "reply_id"
  comment ||--o{ reply : "reply_id"
  comments ||--o{ systemadmin : "comments_id"
  replies ||--o{ systemadmin : "replies_id"
  organization ||--o{ user : "user_id"
  videos ||--o{ user : "videos_id"
  comments ||--o{ user : "comments_id"
  replies ||--o{ user : "replies_id"
  organization ||--o{ video : "video_id"
  user ||--o{ video : "video_id"
  comments ||--o{ video : "comments_id"
  video_folders ||--o{ video : "video_folders_id"
  folders ||--o{ video : "folders_id"
  video ||--o{ videofolder : "videofolder_id"
  folder ||--o{ videofolder : "videofolder_id"
  organization_viewers ||--o{ viewer : "organization_viewers_id"
  organizations ||--o{ viewer : "organizations_id"
  comments ||--o{ viewer : "comments_id"
  replies ||--o{ viewer : "replies_id"
```


## 検出された各種要素
| テーブル名 | カラム数 | 主キー数 | 外部キー数 | belongs_to | has_many | has_one | has_and_belongs_to_many |
| ---------- | -------- | -------- | ---------- | ---------- | -------- | ------- | ---------------------- |
| active_storage_attachments | 5 | 0 | 0 | 0 | 0 | 0 | 0 |
| active_storage_blobs | 8 | 0 | 0 | 0 | 0 | 0 | 0 |
| active_storage_variant_records | 2 | 0 | 0 | 0 | 0 | 0 | 0 |
| comments | 8 | 0 | 0 | 0 | 0 | 0 | 0 |
| folders | 5 | 0 | 0 | 0 | 0 | 0 | 0 |
| organization_viewers | 4 | 0 | 0 | 0 | 0 | 0 | 0 |
| organizations | 5 | 0 | 0 | 0 | 0 | 0 | 0 |
| replies | 8 | 0 | 0 | 0 | 0 | 0 | 0 |
| system_admins | 25 | 0 | 0 | 0 | 0 | 0 | 0 |
| users | 28 | 0 | 0 | 0 | 0 | 0 | 0 |
| video_folders | 4 | 0 | 0 | 0 | 0 | 0 | 0 |
| videos | 14 | 0 | 0 | 0 | 0 | 0 | 0 |
| viewers | 26 | 0 | 0 | 0 | 0 | 0 | 0 |
