Given("one liner with comment") { one; liner } # boo

Given ("one liner with trailing space") { one; line; }  

Given("one liner with no trailing space") { one; liner}

Given ("braces with a comment") { |boo| # yah!
}

Given("braces with a trailing space") { |boo| 
}

Given("braces no trailing space") { |boo|
  yah!
}
