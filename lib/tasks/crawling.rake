require 'open-uri'

namespace :crawling do
  desc '食べログのurlを取得する'
  task tabelog_urls: :environment do
    agent = Mechanize.new
    agent.user_agent_alias = 'iPhone'
    agent.request_headers = {
      'accept-language' => 'ja,en-US;q=0.8,en;q=0.6,zh-CN;q=0.4,zh;q=0.2',
      'Upgrade-Insecure-Requests' => '1',
      'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
    }
    Restaurant.where(tabelog_url: nil).first(100).each do |rst|
      page = agent.get "https://s.tabelog.com/smartphone/restaurant_list/list?utf8=%E2%9C%93&SrtT=rt&tid=&sk=#{rst.name}&svd=20181118&svps=2&svt=1900&LstCos=0&LstCosT=0&LstRev=&LstSitu=0&LstSmoking=0&area_datatype=&area_id=&keyword_datatype=&keyword_id=&LstReserve=0&lat=#{rst.lat}&lon=#{rst.lng}&LstRange=A&lid=redo_search_form&additional_cond_flg=1"
      not_found_msgs = [page.at('#page-header > div.searchword'), page.at('#js-parent-of-floating-element > p')]
      is_not_tabelog_url = (not_found_msgs[0] && not_found_msgs[0].children[1]['class'] == 'rstname-notfound') || (not_found_msgs[1] && not_found_msgs[1].attributes['class'].value == 'not-found')
      tabelog_url = is_not_tabelog_url ? '' : Scraping.format_tabelog_url(page.at('#js-parent-of-floating-element > div.rst-list-group-wrap.js-rst-list-group-wrap > section > div > a').attributes['href'].value)
      rst.update! tabelog_url: tabelog_url
      sleep rand(8)
    end
  end
end
