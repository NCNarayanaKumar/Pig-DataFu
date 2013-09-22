require 'pigudf'
require 'public_suffix'

class Domainfunc < PigUdf
#To use this pigudf: 
#REGISTER 'Domain.rb' USING jruby AS Domainfunc;

  outputSchema "{(name:chararray,sld:chararray,tld:chararray)}"
  def getdomain(domain)
          domain = domain[0..-1]
          nbag = DataBag.new
          if PublicSuffix.valid?(domain.downcase)
                domain = PublicSuffix.parse(domain.downcase)
                sld = domain.sld
                name = domain.domain
                tld = domain.tld
                nbag.add([name, sld, tld])
          end
          nbag
  end
end
