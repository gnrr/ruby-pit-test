require 'mechanize'
require 'kconv'
require 'pit'

class StockPrice
  def initialize(id, pass)
    @agent = Mechanize.new
    login(id, pass)
  end

  def login(id, pass)
    # SBI証券にログイン
    page = @agent.get 'https://k.sbisec.co.jp/bsite/visitor/top.do'
    page.encoding = 'utf-8'
    page.form_with('form1'){|form|
      form['username'] = id
      form['password'] = pass
      form.click_button
    }
  end

  def get(code)
    # 株価データの取得
    page = @agent.get 'https://k.sbisec.co.jp/bsite/price/search.do'
    p page.uri
    form = page.forms[0]
    form['ipm_product_code'] = code
    result = form.click_button
    result.at('font.ltext').text.gsub(/,/, '').to_i
  end

  def out(html)
    File::write('last.html', html)
  end
end

# ----------------------------------

StockList = ['7203',   # トヨタ
             '9984',   # ソフトバンク
]

conf = Pit.get('sbi')
sp = StockPrice.new(conf['id'], conf['pass'])

StockList.each do |code|
  price = sp.get(code)
  p "#{code} の現在値は #{price}円です。"
  sleep 3         # ウェイトを入れないと次を受け付けてくれない
end

