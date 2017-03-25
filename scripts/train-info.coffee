cheerio = require 'cheerio-httpcli'
cronJob = require('cron').CronJob

module.exports = (robot) ->
  # 月~金曜日の7時00分に、定期的にタスクが実行される。
  # cronJobの引数は、秒・分・時間・日・月・曜日の順番
  new cronJob('0 0 7 * * 1-5', () ->
    # 有楽町線(Yahoo!運行情報から選択したURLを設定する。)
    metro_yu = 'http://transit.yahoo.co.jp/traininfo/detail/137/0/'
    # 京浜東北線
    jr_kt = 'http://transit.yahoo.co.jp/traininfo/detail/22/0/'
    searchTrainCron(metro_yu)
    searchTrainCron(jr_kt)
  ).start()

  searchTrainCron = (url) ->
    cheerio.fetch url, (err, $, res) ->
      #路線名(Yahoo!運行情報から正式名称を取得)
      title = "#{$('h1').text()}"

      if $('.icnNormalLarge').length
        # 通常運転の場合
        robot.send {room: "#mybot"}, "#{title}は遅れてないよ。"
      else
        # 通常運転以外の場合
        info = $('.trouble p').text()
        robot.send {room: "#mybot"}, "#{title}は遅れているみたい。\n#{info}"
