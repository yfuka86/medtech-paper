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
    params = {db: 'pubmed', id: id, retmode: 'json'}
    url = BASE_URL + 'efetch.fcgi?' +
      params.map{|k,v| "#{URI.encode(k.to_s)}=#{URI.encode(v.to_s)}"}.join("&")
    response = Net::HTTP.get(URI.parse(url))
    Paper.build_from_pubmed(response)
  end
end
