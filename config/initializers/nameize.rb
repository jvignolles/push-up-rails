# encoding: utf-8
class String
  # "jean-michel d'ôrme" => "Jean-Michel D'Ôrme"
  def nameize
    self.downcase.gsub(/\b(?!['`])[a-záàâäãåāąăæçćčĉċðďđéèêëēęěĕėƒſĝğġģĥħíìîïīĩĭįıĳĵķĸłľĺļŀñńňņŉŋóòôöõøōőŏœÞŕřŗśšşŝșßťţŧțúùûüūůűŭũųŵýŷÿžżź]/i) { $&.mb_chars.capitalize }
  end

  def nameize!
    replace nameize
  end
end

