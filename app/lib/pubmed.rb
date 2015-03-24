class Pubmed
  # 基本的にPaperの未保存インスタンスを返します
  BASE_URL = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/'.freeze

  def self.search(params)
    search_params = {}
    params.each{|k, v| search_params[k.to_sym] = v.dup}
    search_params.merge!({db: 'pubmed', datetype: 'pdat', retmode: 'json'})
    search_params[:mindate].try(:gsub!, '-', '/')
    search_params[:maxdate].try(:gsub!, '-', '/')
    url = BASE_URL + 'esearch.fcgi?' +
      search_params.map{|k,v| "#{URI.encode(k.to_s)}=#{URI.encode(v.to_s)}"}.join("&")
    response = Net::HTTP.get(URI.parse(url))

    result = JSON.parse(response)
    ids = result['esearchresult']['idlist']
    bulk_fetch(ids)
  end

  def self.fetch(id)
    Paper.build_from_pubmed(fetch_params(id)[0], summary_params(id).try(:[], "result").try(:[], "#{id}"))
  end

  def self.bulk_fetch(ids)
    id_str = ids.join(',') if ids.is_a?(Array)
    fetch_results = fetch_params(id_str)
    summary_results = summary_params(id_str)

    result = ids.try(:map) do |id|
      Paper.build_from_pubmed(fetch_results.find{|fetch_result| fetch_result["pmid"] == id},
                              summary_results.try(:[], "result").try(:[], "#{id}"))
    end
    result = result.compact
    result
  end

  def self.fetch_params(id_str)
    params = {db: 'pubmed', id: id_str}
    url = BASE_URL + 'efetch.fcgi?' +
      params.map{|k,v| "#{URI.encode(k.to_s)}=#{URI.encode(v.to_s)}"}.join("&")
    response = Net::HTTP.get(URI.parse(url))
    result = parse_efetch(response)
  end

  def self.summary_params(id_str)
    params = {db: 'pubmed', id: id_str, retmode: 'json'}
    url = BASE_URL + 'esummary.fcgi?' +
      params.map{|k,v| "#{URI.encode(k.to_s)}=#{URI.encode(v.to_s)}"}.join("&")
    response = Net::HTTP.get(URI.parse(url))
    result = JSON.parse(response)
  end

  def self.parse_efetch(str)
    strs = str.split('Pubmed-entry')

    recursion = lambda{|str|
      hash = {}
      cnt = 0
      loop_count = 0
      until str.gsub!(/\A}[,\s]*/, '') || str.length == 0 || loop_count > 1000
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
          str.gsub!(/\A"[^"]*"[,\s]*/, '')
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
        loop_count += 1
      end
      hash
    }

    results = strs.map do |str|
      str.gsub!(/\A([^{]*)/, '')
      recursion.call(str)["0"]
    end
    results = results.reject{|result| result.nil? || (result.is_a?(Hash) && result.empty?)}
  end
end
