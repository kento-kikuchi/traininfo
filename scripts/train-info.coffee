# Description:
#   電車遅延情報をSlackに投稿する
#
# Commands:
#   hubot train < check > - Return train info
#
# Original Author:
#   Kaoru Hotate

cheerio = require 'cheerio-httpcli'
cronJob = require('cron').CronJob

module.exports = (robot) ->

  searchAllTrain = (msg) ->
    # send HTTP request
    baseUrl = 'http://transit.loco.yahoo.co.jp/traininfo/gc/13/'
    cheerio.fetch baseUrl, (err, $, res) ->
      if $('.elmTblLstLine.trouble').find('a').length == 0
        msg.send "事故や遅延情報はありません"
        return
      $('.elmTblLstLine.trouble a').each ->
        url = $(this).attr('href')
        cheerio.fetch url, (err, $, res) ->
          title = "◎ #{$('h1').text()} #{$('.subText').text()}"
          result = ""
          $('.trouble').each ->
            trouble = $(this).text().trim()
            result += "- " + trouble + "\r\n"
          msg.send "#{title}\r\n#{result}"

  robot.respond /train (.+)/i, (msg) ->
    target = msg.match[1]
    # 有楽町線
    metro_yu = 'http://transit.yahoo.co.jp/traininfo/detail/137/0/'
    # 京浜東北線
    jr_kt = 'http://transit.yahoo.co.jp/traininfo/detail/22/0/'
    # 山手線
    jr_ym = 'http://transit.yahoo.co.jp/traininfo/detail/21/0/'
    # 埼京線
    jr_sk = 'http://transit.yahoo.co.jp/traininfo/detail/50/0/'
    # 湘南新宿ライン
    jr_ss = 'http://transit.yahoo.co.jp/traininfo/detail/25/0/'
    # 京王線
    keio = 'http://transit.yahoo.co.jp/traininfo/detail/102/0/'
    # 丸ノ内線
    metro_maru='http://transit.yahoo.co.jp/traininfo/detail/133/0/'
    # 副都心線
    metro_fuku='http://transit.yahoo.co.jp/traininfo/detail/540/0/'

    if target == "check"
      searchTrain(keio, msg)
      searchTrain(metro_maru, msg)
      searchTrain(metro_fuku, msg)
    else if target == "all"
      searchAllTrain(msg)
    else
      msg.send "#{target}は検索できません。"

  searchTrain = (url, msg) ->
    cheerio.fetch url, (err, $, res) ->
      title = "#{$('h1').text()}"
      if $('.icnNormalLarge').length
        msg.send "#{title}は遅延情報がありません。"
      else
        info = $('.trouble p').text()
        msg.send "#{title}は遅延情報があります。\n#{info}"

  new cronJob('0 0 8,18 * * 1-5', () ->
    # 京王線
    keio = 'http://transit.yahoo.co.jp/traininfo/detail/102/0/'
    # 丸ノ内線
    metro_maru='http://transit.yahoo.co.jp/traininfo/detail/133/0/'
    # 副都心線
    metro_fuku='http://transit.yahoo.co.jp/traininfo/detail/540/0/'
    searchTrainCron(keio)
    searchTrainCron(metro_maru)
    searchTrainCron(metro_fuku)
  ).start()

#  new cronJob('0 0 8 * * 1,3,5', () ->
#    # 京王線
#    keio = 'http://transit.yahoo.co.jp/traininfo/detail/102/0/'
#    # 丸ノ内線
#    metro_maru='http://transit.yahoo.co.jp/traininfo/detail/133/0/'
#    # 副都心線
#    metro_fuku='http://transit.yahoo.co.jp/traininfo/detail/540/0/'
#    searchTrainCron(keio)
#    searchTrainCron(metro_maru)
#    searchTrainCron(metro_fuku)
#  ).start()

  searchTrainCron = (url) ->
    cheerio.fetch url, (err, $, res) ->
      title = "#{$('h1').text()}"
      if $('.icnNormalLarge').length
        robot.send {room: "#mybot"}, "#{title}は遅延情報がありません。"
      else
        info = $('.trouble p').text()
        robot.send {room: "#mybot"}, "#{title}は遅延情報があります。\n#{info}"
