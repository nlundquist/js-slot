symbols = [
  "heart glyphicon glyphicon-heart-empty",
  "leaf glyphicon glyphicon-leaf",
  "dollar glyphicon glyphicon-usd",
  "thumb glyphicon glyphicon-thumbs-up"
]

payouts = {
  "three-of-a-kind": 1.25,
  "all-diff": 1.5,
  "leaf,leaf,leaf,leaf": 1.5,
  "heart,heart,heart,heart": 2,
  "dollar,dollar,dollar,dollar": 3,
  "thumb,thumb,thumb,thumb": 4,
}

# wouldn't need these if using a view layer framework
spin_btn_selector = ".output.row .spin.col .btn"
symbol_selector = ".symbol.row .well .glyphicon"
bet_selector = ".output.row .input.col input"
wallet_selector = ".output.row .input.col .wallet"
win_selector = ".output.row .win.col"



#
# Functions to permute the DOM of this simple app, randomizing the
# slot machine symbols and calculating a payout.
#

randomize_symbol = (symbol)->
  symbol.className = symbols[Math.floor(Math.random() * symbols.length)]

calculate_payout = (symbols)->
  symbols_seen = {
    'leaf':0
    'dollar':0
    'thumb':0
    'heart':0
  }
  symbol_names = [symbol.classList[0] for symbol in symbols]
  payout_name = symbol_names.join();
  payout = payouts[payout_name]

  # exit early if we have a simple payout match
  if (payout)
    return payout

  [symbols_seen[symbol.classList[0]]++ for symbol in symbols]
  symbol_counts = (val for key,val of symbols_seen)

  if (symbol_counts.every((v)-> v==1))
    payout_name = "all-diff"

  if (symbol_counts.some((v)-> v==3))
    payout_name = "three-of-a-kind"

  return payouts[payout_name]

make_payout = (payout)->
  bet = parseFloat(document.querySelector(bet_selector).value)
  win_el = document.querySelector(win_selector)
  total = 0 - bet

  if (payout)
    wallet_el = document.querySelector(wallet_selector)
    wallet = parseFloat(wallet_el.innerHTML.substr(1))
    winnings = bet * payout
    wallet_el.innerHTML = '$'+(wallet + winnings)
    total = total + winnings

  if (total > 0)
    win_el.innerHTML = "<h4 class='text-success'>Won: $" + total + "</h4>"
  else
    win_el.innerHTML = "<h4 class='text-danger'>Lost: $" + Math.abs(total) + "</h4>"

subtract_bet = ->
  bet = parseFloat(document.querySelector(bet_selector).value)
  wallet_el = document.querySelector(wallet_selector)
  wallet = parseFloat(wallet_el.innerHTML.substr(1))
  wallet_el.innerHTML = '$'+(wallet - bet);

spin = (symbols)->
  subtract_bet()
  (randomize_symbol(symbol) for symbol in symbols)
  make_payout(calculate_payout(symbols))



#
# Bind functions to view, in a more complicated example this would all be done
# with a view technology that provides data binding
#
document.addEventListener('DOMContentLoaded', ()->
  # spin handler
  document.querySelector(spin_btn_selector).addEventListener('click', ()->
    spin(document.querySelectorAll(symbol_selector))
  )
)