--version = 1.1.0

SMODS.Atlas {
  key = "sprite_sheet",

  path = "sprite_sheet.png", 

  px = 72,

  py = 96
}

SMODS.Joker {
  key = 'theGambler',
  loc_txt = {
    name = 'The Gambler',
    text = {
      "This card gains {X:mult,C:white}x1{} mult when {C:attention}Two Pair{} is played",
      --"Each {C:attention}Two Pair{} {X:mult,C:white}x1{}",
      "{C:inactive}(Currently {X:mult,C:white}x#1#{C:inactive})" 
    }
  },
  config = { extra = { mult = 1 } },
  loc_vars = function(self, info_queue, card)
    return { vars = { card.ability.extra.mult } }
  end,
  rarity = 4,
  atlas = 'sprite_sheet', 
  cost = 12,

  pos = { x = 2, y = 0 },
  
  calculate = function(self, card, context)

    if context.scoring_name == "Two Pair" and context.before then
      card.ability.extra.mult = card.ability.extra.mult + 1

      return {
        message = 'Upgrade',
        colour = G.C.MULT,
        card = card
      }
    end


       
  
    if context.joker_main then
      return {
        Xmult_mod = card.ability.extra.mult, 

        message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.mult } }
      }
    end
    
    

  end
}

SMODS.Joker {
  key = 'theHitman',  
  loc_txt = {
    name = 'The Hitman',
    text = {
      "Scoring face cards are destroyed and", 
      "replaced with 10's of a {C:attention}random suit{}"
      --"All face cards get turned into 10 cards of a",
      --"{C:attention}random{} {C:attention}suit{}"
    }
  },
  rarity = 2,
  pos = {x = 3, y = 0},
  cost = 3,
  atlas = 'sprite_sheet',

  calculate = function(self, card, context)
    if context.before and not context.blueprint then
      local facesTransformed = false
      local suits = {'S', 'H', 'D', 'C'}

      for i = 1, #context.scoring_hand do
        local scoring_card = context.scoring_hand[i]


        if scoring_card:is_face() then
          --local randomSuit = suits[pseudorandom('hitman_suit'..G.GAME.round_resets.ante) * #suits + 1]
        
          local randomSuit = pseudorandom_element(suits, pseudoseed('hitman'))
  
          scoring_card:set_base(G.P_CARDS[randomSuit..'_T'])
          facesTransformed = true
        end
      end


      if facesTransformed == true then
        return {
          message = 'Assassinated!',
          colour = G.C.FILTER,
          card = card
        }
      end
    end
  end

}

  
SMODS.Joker {
  key = 'thePi',
  loc_txt = {
    name = 'The Pi',
    text = {
      "If {C:attention}Three of a Kind{} is played",
      "this joker adds {X:mult,C:white}+14{} to mult."
    }
  },
  config = {extra = {mult = 14} },
  rarity = 3,
  pos = {x = 4, y = 0},
  cost = 5,
  atlas = 'sprite_sheet',
  loc_vars = function(self, info_queue, card)
    return {vars = {card.ability.extra.mult}}
  end,

  calculate = function(self, card, context)
  
    if context.scoring_name == "Three of a Kind" and context.joker_main then
      return {
        mult_mod = card.ability.extra.mult,

        message = localize {type = 'variable', key = 'a_mult', vars = {card.ability.extra.mult} }
      }
    end
  end
}


SMODS.Joker {
  key = 'theChauffeur',
  loc_txt = {
    name = 'The Chauffeur',
    text = {
      "{C:attention}Retriggers{} first two cards"
    }
  },
  config = {extra = {repetitions = 1} },
  rarity = 3,
  pos = {x = 1, y = 0},
  cost = 8,
  atlas = 'sprite_sheet',

  calculate = function(self, card, context)

    if context.repetition and context.cardarea == G.play then

      for _ = 1, 2 do
        if context.other_card == context.full_hand[_] then
          return {
            message = 'Again!',
            repetitions = card.ability.extra.repetitions,
            card = card
          }
        end
      end
    end
  end
}


SMODS.Joker {
  key = 'theBodyguard',
  loc_txt = {
    name = 'The Bodyguard',
    text = {
      "{C:chips}-5{} and {X:mult,C:white}+3{}",
      "for each face card triggered"    
    }
  },
  config = { extra = {chips = -5, mult = 3}},
  rarity = 2,
  pos = {x = 0, y = 0},
  cost = 5,
  atlas = 'sprite_sheet',
  loc_vars = function(self, info_queue, card)
    return {vars = {card.ability.extra.mult, card.ability.extra.chips} }
  end,
  
  calculate = function(self, card, context)

    if context.individual and context.cardarea == G.play then
      if context.other_card:is_face() then
        return {
          mult = card.ability.extra.mult,
          chips = card.ability.extra.chips,
          card = card
        }
      end
    end
  end
      
  
}

