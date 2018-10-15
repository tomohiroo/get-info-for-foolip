# == Route Map
#
#                    Prefix Verb   URI Pattern                                                                              Controller#Action
#         komachi_heartbeat        /ops                                                                                     KomachiHeartbeat::Engine
#                  v1_users GET    /v1/users(.:format)                                                                      v1/users#index {:format=>:json}
#                           POST   /v1/users(.:format)                                                                      v1/users#create {:format=>:json}
#    distance_v1_restaurant GET    /v1/restaurants/:id/distance(.:format)                                                   v1/restaurants#distance {:format=>:json}
#            v1_restaurants GET    /v1/restaurants(.:format)                                                                v1/restaurants#index {:format=>:json}
#            share_v1_clips POST   /v1/clips/share(.:format)                                                                v1/clips#share {:format=>:json}
#                  v1_clips GET    /v1/clips(.:format)                                                                      v1/clips#index {:format=>:json}
#                           POST   /v1/clips(.:format)                                                                      v1/clips#create {:format=>:json}
#                   v1_clip GET    /v1/clips/:id(.:format)                                                                  v1/clips#show {:format=>:json}
#                           PATCH  /v1/clips/:id(.:format)                                                                  v1/clips#update {:format=>:json}
#                           PUT    /v1/clips/:id(.:format)                                                                  v1/clips#update {:format=>:json}
#                           DELETE /v1/clips/:id(.:format)                                                                  v1/clips#destroy {:format=>:json}
#                 v1_boards GET    /v1/boards(.:format)                                                                     v1/boards#index {:format=>:json}
#                           POST   /v1/boards(.:format)                                                                     v1/boards#create {:format=>:json}
#                  v1_board GET    /v1/boards/:id(.:format)                                                                 v1/boards#show {:format=>:json}
#                           PATCH  /v1/boards/:id(.:format)                                                                 v1/boards#update {:format=>:json}
#                           PUT    /v1/boards/:id(.:format)                                                                 v1/boards#update {:format=>:json}
#                           DELETE /v1/boards/:id(.:format)                                                                 v1/boards#destroy {:format=>:json}
#        v1_clip_categories POST   /v1/clip_categories(.:format)                                                            v1/clip_categories#create {:format=>:json}
#          v1_clip_category DELETE /v1/clip_categories/:id(.:format)                                                        v1/clip_categories#destroy {:format=>:json}
#             v1_categories GET    /v1/categories(.:format)                                                                 v1/categories#index {:format=>:json}
#               v1_stations GET    /v1/stations(.:format)                                                                   v1/stations#index {:format=>:json}
#        rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
# rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#        rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
# update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#      rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create
#
# Routes for KomachiHeartbeat::Engine:
#    heartbeat GET  /heartbeat(.:format)    komachi_heartbeat/heartbeat#index {:format=>"txt"}
#      version GET  /version(.:format)      komachi_heartbeat/heartbeat#version
# stats_worker GET  /stats/worker(.:format) komachi_heartbeat/stats#worker

Rails.application.routes.draw do
end
