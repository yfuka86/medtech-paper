class Pubmed
  # 基本的にPaperの未保存インスタンスを返します
  BASE_URL = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/'.freeze

  def self.search(params)
    params = params.clone
    params.merge!({db: 'pubmed', datetype: 'pdat', retmode: 'json'})
    params[:min_date].gsub!('-', '/')
    params[:max_date].gsub!('-', '/')
    url = BASE_URL + 'esearch.fcgi?' +
      params.map{|k,v| "#{URI.encode(k.to_s)}=#{URI.encode(v.to_s)}"}.join("&")
    response = Net::HTTP.get(URI.parse(url))

    result = JSON.parse(response)
    ids = result['esearchresult']['idlist']
    ids.map{|id| self.fetch(id)}
  end

  def self.fetch(id)
    Paper.build_from_pubmed(fetch_params(id), summary_params(id))
  end

  def self.fetch_params(id)
    params = {db: 'pubmed', id: id}
    url = BASE_URL + 'efetch.fcgi?' +
      params.map{|k,v| "#{URI.encode(k.to_s)}=#{URI.encode(v.to_s)}"}.join("&")
    response = Net::HTTP.get(URI.parse(url))
    result = parse_efetch(response)
  end

  def self.summary_params(id)
    params = {db: 'pubmed', id: id, retmode: 'json'}
    url = BASE_URL + 'esummary.fcgi?' +
      params.map{|k,v| "#{URI.encode(k.to_s)}=#{URI.encode(v.to_s)}"}.join("&")
    response = Net::HTTP.get(URI.parse(url))
    result = JSON.parse(response)
  end

  def self.parse_efetch(str)
    str.gsub!(/\A([^{]*)/, '')

    recursion = lambda{|str|
      hash = {}
      cnt = 0
      until str.gsub!(/\A}[,\s]*/, '') || str.length == 0
        if /\A([a-zA-Z][a-zA-Z\-\s]*)/ =~ str
          key = $1.strip
          key = key.gsub(/std\z/, '').strip if /std\z/.match(key)
          str.gsub!(/\A([a-zA-Z][a-zA-Z\-\s]*)/, '')
        end

        if /\A(\d+)/ =~ str
          hash[key] = $1
          str.gsub!(/\A\d+[,\s]*/,'')
        elsif /\A"([^"]+)/ =~ str
          hash[key] = $1
          str.gsub!(/\A"[^"]+"[,\s]*/, '')
        elsif str.gsub!(/\A{[\s]*/, '')
          if key
            hash[key] = recursion.call(str)
          else
            hash[cnt.to_s] = recursion.call(str)
            cnt += 1
          end
        else
          hash[key] = ''
          str.gsub!(/\A[,\s]*/,'')
        end
      end
      hash
    }

    recursion.call(str)["0"]
  end
end
