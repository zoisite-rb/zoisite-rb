# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-zoisite", to: "turbo.min.js", preload: true
pin "trix"
pin "@zoisite/actiontext", to: "actiontext.esm.js"
