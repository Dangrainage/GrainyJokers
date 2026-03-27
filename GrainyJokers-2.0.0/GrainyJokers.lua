--version = 2.0.0

SMODS.Atlas {
  key = "sprite_sheet",

  path = "sprite_sheet.png", 

  px = 72,

  py = 96
}


local function flipTransformation(card, transformCardKey, delayValue)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = delayValue or 0.15,
        func = function()
            card:flip()
            play_sound('card1', 1)
            card:juice_up(0.3, 0.3)
            return true
        end
    }))
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.3,
        func = function()
            card:set_base(G.P_CARDS[transformCardKey])
            return true
        end
    }))
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.15,
        func = function()
            card:flip()
            play_sound('tarot2', 1.2, 0.6)
            return true
        end
    }))
end

-- I totally didn't yoink this code from elsewhere....
-- example:
-- flipTransformation(sc, 'H_K') -- Changes the 2 into a King of Hearts



SMODS.Joker {
  key = 'theGambler',
  loc_txt = {
    name = 'The Gambler',
    text = {
      "This card gains {X:mult,C:white}x0.25{} mult when {C:attention}Two Pair{} is played",
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

  pos = { x = 3, y = 0 },
  
  calculate = function(self, card, context)

    if context.scoring_name == "Two Pair" and context.before then
      card.ability.extra.mult = card.ability.extra.mult + 0.25

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
  pos = {x = 5, y = 0},
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
        
          local randomSuit = pseudorandom_element(suits, pseudoseed('hitman'..G.GAME.round_resets.ante) * #suits + 1 - i)

            flipTransformation(scoring_card, randomSuit..'_T', 0.5)
          --scoring_card:set_base(G.P_CARDS[randomSuit..'_T'])
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
  pos = {x = 7, y = 0},
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
  pos = {x = 2, y = 0},
  cost = 8,
  atlas = 'sprite_sheet',

  calculate = function(self, card, context)

    if context.repetition and context.cardarea == G.play then

      for _ = 1, 2 do
        if context.other_card == context.scoring_hand[_] then
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
  pos = {x = 1, y = 0},
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

SMODS.Joker {
	key = 'jackRabbit',
	loc_txt = {
		name = 'Jack Rabbit',
		text = {
			"All scoring Jacks become clubs"
		}
	},
	rarity = 1,
	pos = {x = 0, y = 0},
	cost = 3,
	atlas = 'sprite_sheet',
	

	calculate = function(self, card, context)
		if context.before and not context.blueprint then
			local jacksTransformed = false
			local suit = 'C'

			for i = 1, #context.scoring_hand do
				local scoring_card = context.scoring_hand[i]

				if scoring_card:get_id() == 11 then
					--scoring_card:set_base(G.P_CARDS[suit..'_J'])
					flipTransformation(scoring_card, 'C_J')
					jacksTransformed = true
				end
			end

			if jacksTransformed == true then
				return {
					message = 'Magic!',
					colour = G.C.FILTER,
					card = card
				}
			end
		end
	end

}

SMODS.Joker {
  key = 'theLookout',
  loc_txt = {
    name = 'The Lookout',
    text = {
      "If scoring hand has a face card",
      "earn {C:money}2${}"
    }
  },
  rarity = 2,
  pos = {x = 6,y = 0},
  cost = 5,
  atlas = 'sprite_sheet',

  calculate = function(self, card, context)
    if context.before then
      local facesDetected = false

      for i = 1, #context.scoring_hand do
        local scoring_card = context.scoring_hand[i]

        if scoring_card:is_face() then
          facesDetected = true
          break
        end
      end

      if facesDetected == true then
        ease_dollars(2)
        return {
          message = 'Reported!',
          colour = G.C.MONEY,
          card = card
        }
      
      end
    end
  end
}


SMODS.Joker {
  key = 'theSpy',
  loc_txt = {
    name = 'The Spy',
    text = {
      "If pair is played and contains only",
      "2s, change them to kings of hearts"
    }
  },
    rarity = 2,
    cost = 5,
    atlas = 'sprite_sheet',
    pos = {x = 9, y= 0},

    calculate = function(self, card, context)
      local cardsTransformed = false
    
      if context.before and not context.blueprint and context.scoring_name == "Pair" then
        for i = 1, #context.scoring_hand do 
          local scoringCard = context.scoring_hand[i]

          if scoringCard:get_id() == 2 then
            --scoringCard:set_base(G.P_CARDS['H_K'])
            flipTransformation(scoringCard, 'H_K')
            --play_sound('foil1', 1.2, 0.4)
            cardsTransformed = true
          end
        end
      end
        
        if cardsTransformed == true then
          card:juice_up(0.5, 0.5)
          --play_sound('card1')
          return {
            message = 'Promotion!',
            colour = G.C.FILTER,
            card = card
          }
        end
      end
  }



SMODS.Joker {
  key = 'theHandgun',
  loc_txt = {
    name = 'The Handgun',
    text = {
      "{X:mult,C:white}+20{} mult",
      "{C:green}#1# in #2#{} chance to destroy jokers to",
      "left and right"
    }
  },
  rarity = 1,
  cost = 4,
  atlas = 'sprite_sheet',
  pos = {x = 4, y = 0},

  chance = 6,

  loc_vars = function(self, info_queue, card)
    return {vars = { G.GAME.probabilities.normal, 6  } }
  end,



  calculate = function(self, card, context)
    local destroyed = false



    if context.joker_main then
      return {
        mult_mod = 20,
        message = localize {type = 'variable', key = 'a_mult', vars = {20}}
      }
    end
    
  
    if context.before and not context.blueprint and pseudorandom('!handgunJoKeR') < G.GAME.probabilities.normal / 6 then
      for i, t in ipairs(G.jokers.cards) do
        if G.jokers.cards[i] == card then
          if G.jokers.cards[i-1] and not G.jokers.cards[i-1].ability.eternal then
            G.jokers.cards[i-1]:start_dissolve()
            destroyed = true
          end
          if G.jokers.cards[i+1] and not G.jokers.cards[i+1].ability.eternal then
            G.jokers.cards[i+1]:start_dissolve()
            destroyed = true
          end
          break
        end
      end
    end

  if destroyed == true then
    return {
      message = 'Misfire!',
      colour = G.C.FILTER,
      card = card
    }
  --else
    --return {
      --message = 'Safety on!',
      --colour = G.C.FILTER,
      --card = card
    --}
  end
end
}

SMODS.Joker {
  key = 'thePianist',
  loc_txt = {
    name = 'The Pianist',
    text = {"Retriggers all scoring cards"}
  },
  config = { extra = {repetitions = 1}},
  rarity = 3,
  cost = 10,
  atlas = 'sprite_sheet',
  pos = {x = 8, y = 0},

  calculate = function(self, card, context)
  
    if context.repetition and context.cardarea == G.play then

      for t = 1, 5 do 
        if context.other_card == context.scoring_hand[t] then
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

