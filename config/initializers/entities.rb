# encoding: utf-8
module Entities
  def self.decode(html)
    res = html.gsub(ENTITIES_REGEX) { |entity|
      ENTITIES[$1] ? ENTITIES[$1][:char] : ($1.to_i.between?(32,255) ? $1.to_i.chr : entity)
    }
    res = res.gsub(/'|&#8217;/, '’').gsub('&#160;', ' ').gsub(/\s*×\s*/, ' × ') # for some reason &#160; goes through?!
  end

private
  ENTITIES = {
    # XML special characters
    'amp'    => { :decimal =>  38, :char => '&' },  'lt'     => { :decimal =>  60, :char => '<' },
    'gt'     => { :decimal =>  62, :char => '>' },  'quot'   => { :decimal =>  34, :char => '"' },
    'apos'   => { :decimal =>  39, :char => "'" },
    # ISO-8859-x symbols
    'nbsp'   => { :decimal => 160, :char => ' ' },  'iexcl'  => { :decimal => 161, :char => '¡' },
    'cent'   => { :decimal => 162, :char => '¢' },  'pound'  => { :decimal => 163, :char => '£' },
    'curren' => { :decimal => 164, :char => '¤' },  'yen'    => { :decimal => 165, :char => '¥' },
    'brvbar' => { :decimal => 166, :char => '¦' },  'sect'   => { :decimal => 167, :char => '§' },
    'uml'    => { :decimal => 168, :char => '¨' },  'copy'   => { :decimal => 169, :char => '©' },
    'ordf'   => { :decimal => 170, :char => 'ª' },  'laquo'  => { :decimal => 171, :char => '«' },
    'not'    => { :decimal => 172, :char => '¬' },  'shy'    => { :decimal => 173, :char => '­' },
    'reg'    => { :decimal => 174, :char => '®' },  'macr'   => { :decimal => 175, :char => '¯' },
    'deg'    => { :decimal => 176, :char => '°' },  'plusmn' => { :decimal => 177, :char => '±' },
    'sup2'   => { :decimal => 178, :char => '²' },  'sup3'   => { :decimal => 179, :char => '³' },
    'acute'  => { :decimal => 180, :char => '´' },  'micro'  => { :decimal => 181, :char => 'µ' },
    'para'   => { :decimal => 182, :char => '¶' },  'middot' => { :decimal => 183, :char => '·' },
    'cedil'  => { :decimal => 184, :char => '¸' },  'sup1'   => { :decimal => 185, :char => '¹' },
    'ordm'   => { :decimal => 186, :char => 'º' },  'raquo'  => { :decimal => 187, :char => '»' },
    'frac14' => { :decimal => 188, :char => '¼' },  'frac12' => { :decimal => 189, :char => '½' },
    'frac34' => { :decimal => 190, :char => '¾' },  'iquest' => { :decimal => 191, :char => '¿' },
    'times'  => { :decimal => 215, :char => '×' },  'divide' => { :decimal => 247, :char => '÷' },
    'ndash'  => { :decimal => 8211, :char => '-' }, 'mdash'  => { :decimal => 8212, :char => '-' },
    'lsquo'  => { :decimal => 8216, :char => '‘' }, 'rsquo'  => { :decimal => 8217, :char => '’' },
    'hellip' => { :decimal => 8230, :char => '…' }, 'euro'   => { :decimal => 8364, :char => '€' },
    # ISO-8859-x alphabet
    'Agrave' => { :decimal => 192, :char => 'À' },  'Aacute' => { :decimal => 193, :char => 'Á' },
    'Acirc'  => { :decimal => 194, :char => 'Â' },  'Atilde' => { :decimal => 195, :char => 'Ã' },
    'Auml'   => { :decimal => 196, :char => 'Ä' },  'Aring'  => { :decimal => 197, :char => 'Å' },
    'AElig'  => { :decimal => 198, :char => 'Æ' },  'Ccedil' => { :decimal => 199, :char => 'Ç' },
    'Egrave' => { :decimal => 200, :char => 'È' },  'Eacute' => { :decimal => 201, :char => 'É' },
    'Ecirc'  => { :decimal => 202, :char => 'Ê' },  'Euml'   => { :decimal => 203, :char => 'Ë' },
    'Igrave' => { :decimal => 204, :char => 'Ì' },  'Iacute' => { :decimal => 205, :char => 'Í' },
    'Icirc'  => { :decimal => 206, :char => 'Î' },  'Iuml'   => { :decimal => 207, :char => 'Ï' },
    'ETH'    => { :decimal => 208, :char => 'Ð' },  'Ntilde' => { :decimal => 209, :char => 'Ñ' },
    'Ograve' => { :decimal => 210, :char => 'Ò' },  'Oacute' => { :decimal => 211, :char => 'Ó' },
    'Ocirc'  => { :decimal => 212, :char => 'Ô' },  'Otilde' => { :decimal => 213, :char => 'Õ' },
    'Ouml'   => { :decimal => 214, :char => 'Ö' },  'Oslash' => { :decimal => 216, :char => 'Ø' },
    'Ugrave' => { :decimal => 217, :char => 'Ù' },  'Uacute' => { :decimal => 218, :char => 'Ú' },
    'Ucirc'  => { :decimal => 219, :char => 'Û' },  'Uuml'   => { :decimal => 220, :char => 'Ü' },
    'Yacute' => { :decimal => 221, :char => 'Ý' },  'THORN'  => { :decimal => 222, :char => 'Þ' },
    'szlig'  => { :decimal => 223, :char => 'ß' },  'agrave' => { :decimal => 224, :char => 'à' },
    'aacute' => { :decimal => 225, :char => 'á' },  'acirc'  => { :decimal => 226, :char => 'â' },
    'atilde' => { :decimal => 227, :char => 'ã' },  'auml'   => { :decimal => 228, :char => 'ä' },
    'aring'  => { :decimal => 229, :char => 'å' },  'aelig'  => { :decimal => 230, :char => 'æ' },
    'ccedil' => { :decimal => 231, :char => 'ç' },  'egrave' => { :decimal => 232, :char => 'è' },
    'eacute' => { :decimal => 233, :char => 'é' },  'ecirc'  => { :decimal => 234, :char => 'ê' },
    'euml'   => { :decimal => 235, :char => 'ë' },  'igrave' => { :decimal => 236, :char => 'ì' },
    'iacute' => { :decimal => 237, :char => 'í' },  'icirc'  => { :decimal => 238, :char => 'î' },
    'iuml'   => { :decimal => 239, :char => 'ï' },  'eth'    => { :decimal => 240, :char => 'ð' },
    'ntilde' => { :decimal => 241, :char => 'ñ' },  'ograve' => { :decimal => 242, :char => 'ò' },
    'oacute' => { :decimal => 243, :char => 'ó' },  'ocirc'  => { :decimal => 244, :char => 'ô' },
    'otilde' => { :decimal => 245, :char => 'õ' },  'ouml'   => { :decimal => 246, :char => 'ö' },
    'oslash' => { :decimal => 248, :char => 'ø' },  'ugrave' => { :decimal => 249, :char => 'ù' },
    'uacute' => { :decimal => 250, :char => 'ú' },  'ucirc'  => { :decimal => 251, :char => 'û' },
    'uuml'   => { :decimal => 252, :char => 'ü' },  'yacute' => { :decimal => 253, :char => 'ý' },
    'thorn'  => { :decimal => 254, :char => 'þ' },  'yuml'   => { :decimal => 255, :char => 'ÿ' },
  }
  ENTITIES.values.dup.each do |definition|
    ENTITIES[definition[:decimal].to_s] = definition
  end
  ENTITIES_REGEX = /&#?([^;]+);/
end

