# Forked User Manual

## Welcome to Forked
Forked is a scripting system for DragonRuby that lets you write interactive stories, branching dialogues or anything else that requires writing and choices like, for example, this manual.

Forked is intended to be simple to pick up and easy for non-programmers to work with. For people who like to write code, it lets you focus on story-writing while giving you access to the full power of Ruby.

With Forked, you can learn how to write a simple interactive story in a few minutes.

---
[Next: Getting Started](#getting-started)
[Contents](#contents)

## Contents

[Welcome to Forked](#welcome-to-forked)
[Getting Started](#getting-started)
[Essentials](#essentials)
[Formatting](#formatting)
[Actions and Conditions](#actions-and-conditions)
[Built-in Commands](#built-in-commands)
[Examples](#examples)

## Getting Started

First things first. You need DragonRuby Game Toolkit to use Forked:

[Get DragonRuby](#dragonruby-game-toolkit)

Then you can install Forked:

[Install and Run Forked](#installation)

Now you can run Forked and start writing your story.

[Start Writing](#writing-and-editing-the-story)

---

[Next: Essentials](#essentials)  
[Back: Welcome to Forked](#welcome-to-forked)  
[Contents](#contents)


## DragonRuby Game Toolkit

If you're reading this, you probably already own DragonRuby and you probably also have it installed and working.

If not, you can find more information about DragonRuby at https://dragonruby.itch.io/dragonruby-gtk.

Be sure to visit the DragonRuby Discord for help or just to hang out with the super-friendly community: http://discord.dragonruby.org.

---
[Back: Getting Started](#getting-started)

## Installation
To install Forked, you should start with a freshly unzipped DragonRuby project.

Download the Forked project from GitHub and move the files into your DragonRuby project.

Copy/paste or drag the `Forked` folder into the `mygame/app` folder. Copy or drag the file `main.rb` into `mygame/app` and let it overwrite the existing file.

Now run DragonRuby: double-click on the DragonRuby executable (`dragonruby.exe` on windows, `dragonruby` on macOS or Linux).

By default, Forked will open this manual to help you get started. Since you're already reading this manual, congratulations on a job well done.

---
[Back: Getting Started](#getting-started)

## Writing and Editing the Story

Open up the `app/story.md` file in any text editor and you'll see the contents of this manual. When you look at the examples, you'll also be able to see the code that created them.

When you want to start a new story, create a new file in the `app` folder and call it whatever you want.

Open the `main.rb` file and look for a line near the top that says

~~~
STORY_FILE = 'app/story.md'
~~~

Change `story.md` to whatever you named your file.

Then you can start writing your story:

---

[Back: Getting Started](#getting-started)

## Essentials

There are only a few things you really need to know to write a branching story with Forked.

[Set The Story Title](#the-story-title)
[Divide the Story into Chunks](#story-chunks)
[Give Each Chunk a Heading](#heading-lines)
[Add Some Text](#adding-text)
[Link Chunks to Each Other with Triggers](#triggers)

Once you've covered that, you can write a simple branching story and share it with the world.

---
[Next: Formatting](#formatting)
[Back: Getting Started](#getting-started)
[Contents](#contents)

## The Story Title
Every story needs a title and, in Forked, they are written like this:

~~~
# Gentleman, Adventurer, Amphibian: A Memoir
~~~

The title begins with a hash (also know as a pound) symbol `#` followed by the text of the title.

You can have only one title in your story file and it should be at the top.

That's all for titles.

---
[Next: Story Chunks](#story-chunks)
[Back to Essentials](#essentials)

## Story Chunks
In Forked, stories are divided into sections called chunks. All the text you can see in this window is one chunk of the story.

With Forked, you can easily link chunks together so the player can click a button and go to a different chunk. You've already seen this happening.

And you'll see it happen again when you click one of the buttons below.

---
[Next: The Heading Line](#heading-lines)
[Back: The Story Title](#the-story-title)
[Back to Essentials](#essentials)

## Heading Lines
The first line of a chunk is the heading line. It's what lets Forked know that a new chunk is beginning.

~~~
## The Day I Was Born
~~~

The heading line begins with two hash symbols ##. 

Next is the text of the heading (The Day I Was Born). This will be shown at the top of the screen when the chunk is displayed.

---
[Next: Adding Text](#adding-text)
[Back: Story Chunks](#story-chunks)
[Back to Essentials](#essentials)

## Adding Text

Now that you have your heading line, you can start writing text underneath it.

~~~
## The Day I Was Born 

My story begins on the day of my birth, though I do not remember much of that occasion.

My mother has never discussed it with me. Being a typical crocodile of the West African species, she is not much for conversation.
~~~

In Forked, you write text in paragraphs separated by a blank line.

---
[Next: Triggers](#triggers)
[Back: Heading Lines](#heading-lines)
[Back to Essentials](#essentials)

## Triggers
To allow the player to move from one chunk to another, we can use Triggers. Triggers are displayed as buttons and can be clicked to perform actions, such as navigate to a different chunk in the story.

~~~
[Learn more about my birth](#crocodile-parenting)
~~~

Triggers have two parts, the trigger text (`Learn more about my birth`), surrounded by two square brackets `[]` and the trigger action (`#crocodile-parenting`), surrounded by two round brackets `()`.

The trigger action is the text of the header you want to link to in the form of a "slug". The slug is the same text as the header but it can only include lowercase letters, hyphens (`-`) and underscores (`_`). Spaces must be replaced with hyphens (`-`).

Clicking the `Learn more about my birth` trigger in the example above will take the player to the chunk with the heading `## Crocodile Parenting`.

As well as navigating to other chunks, trigger actions can run Ruby code. We'll see more about that later.

If the trigger action is empty, Forked will display a non-clickable button:
```md
[You cannot click on this button]()
```

---
[Back: Adding Text](#adding-text)
[Back to Essentials](#essentials)

## Formatting

Now that you know how to write a story, we can do a few things about the way it looks.

Simple formatting:
[Styling Text](#inline-text-styles)
[Blockquotes](#blockquotes)
[Code Blocks](#code-blocks)
[Horizontal Rules](#horizontal-rules)

Related: For more advanced formatting:
[Themes]()

Expect to see more formatting options added in future.

---
[Next: Actions](#actions-and-conditions)
[Back: Essentials](#essentials)
[Contents](#contents)

## Inline Text Styles

Make text appear *in italics* by putting asterisks `*` around it:

~~~md
*This text is in italics.* **This text is bold.** ***This text is in bold italics.***
~~~
*This text is in italics.* **This text is bold.** ***This text is in bold italics.***

Note that you can also use underscores `_` instead of asterisks.

Make text appear as `code` by putting backticks ` around it:

~~~md
This line has `some code` in it
~~~
This line has `some code` in it

Inline styles may also be used with blockquotes.
---
[Back to Formatting](#formatting)

## Blockquotes
Blockquotes put your text in a box:
> The Maharajah's Star is a diamond of great renown.

To make a blockquote, start the line with a right angle bracket >
~~~
> The Maharajah's Star is a diamond of great renown.
~~~

If you put several blockquotes one after the other, they appear as a single blockquote:
~~~
> Many people have tried to steal it over the centuries.
> *All of them perished*.
> ***Horribly***.
~~~

> Many people have tried to steal it over the centuries.
> *All of them perished*.
> ***Horribly***.

As you have just seen, inline styles may also be used in blockquotes.
---
[Back to Formatting](#formatting)

## Code Blocks
Code blocks, as you have already seen in this manual, are used to show code:
~~~
bag_add "The Maharajah's Star"
~~~

Code blocks start and end with three tildes ~
~~~
\~~~
  bag_add "The Maharajah's Star"
\~~~
~~~

Code blocks present text 'as-is', without any formatting changes except for wrapping long lines.

Not every story will need to have code blocks. It's super-useful for manuals though.

---
[Back to Formatting](#formatting)

## Horizontal Rules
You can draw a horizontal line anywhere in your story like this one:

---

To draw a line you just put three dashes (also known as hyphens) `-` at the start of a line:
~~~
---
~~~

This manual uses horizontal rules to separate the content from the navigational buttons at the bottom of each chunk, but you can use them wherever you like. You can also use as many as you like:

---
---
---

---
[Back to Formatting](#formatting)

## Themes

## Actions and Conditions
Actions get things done. They are short pieces of code that you can put directly into your story to perform some common tasks. You can use actions to tell Forked to do something, remember something, count something, time something, roll dice, go to another chunk, and other things besides.

There are three ways to use actions. Chunk Actions perform tasks when the chunk gets displayed like, for example, adding an item to the inventory. Trigger actions make something happen when a player clicks a button like, for example, remembering a choice. Conditions  make decisions like which text to display or which buttons should be visible.

[Chunk Actions](#chunk-actions)
[Trigger Actions](#trigger-actions)
[Conditions](#conditional-text-part-1)
Related: Forked includes a number of useful commands you can use with actions.
[Built-in Commands](#built-in-commands)

---
[Next: Commands](#built-in-commands)
[Back: Formatting](#formatting)
[Contents](#contents)

## Chunk Actions

You can drop an action into a chunk like this:

~~~
:: bag_add "pith helmet" ::
~~~
Chunk Actions begin and end with a pair of colon `:` symbols. Between the symbols, you can issue commands.

In this case, we are telling Forked to add a sturdy, yet attractive, "pith helmet" to the player's "bag" or inventory. Forked comes with some useful commands included, including the ability to store and retrieve items from an inventory. More about custom commands later.

When you drop an action into a chunk like this, it will run once, each time this chunk is loaded. That's the perfect time to add an item to, or remove an item from, your bag.

You can put commands on multiple lines, like this:
~~~
::
  bag_add "pith helmet"
  bag_remove "top hat"
::
~~~
---
[Next: Trigger Actions](#trigger-actions)
[Back to Actions](#actions-and-conditions)

## Trigger Actions

Sometimes you will want a trigger to perform some kind of action instead of navigating to another chunk.

~~~
[Drop the weapon](: bag_remove "duelling pistol" :)
~~~

You can combine an action with a trigger by adding the colons above and replacing the chunk id with a command.

In this case, the item "duelling pistol" will be removed from the player's bag when the button is clicked.

You can put commands on multiple lines:
~~~
[Drop the weapon](:
  bag_remove "duelling pistol"
  jump "#surrender"
:)
~~~
The `jump` command lets you navigate to another chunk from a trigger action.
---
[Next: Conditional Text](#conditional-text-part-1)
[Back: Chunk Actions](#chunk-actions)
[Back to Actions](#actions-and-conditions)

## Conditional Text Part 1
Sometimes you may want to show, hide or change text depending on the situation. Forked gives you a couple of ways to do this. The first lets you insert words or short pieces of text into the story.
~~~
Any fool knows that 
<:
  memo_check "dauphine_fave_color"
:> 
is the Dauphine's favourite colour!
~~~

One of the useful tools included with Forked is `memo` and it lets you remember and recall pieces of text like, for example, a character's favourite colour. If the dauphine's favourite colour is "Moroccan pink", the following text will be added into the story:

> Any fool knows that Moroccan pink is the Dauphine's favourite colour!

We'll learn more about `memo` and other included commands later.

---
[Next: Conditions Part 2](#conditional-text-part-2)
[Back: Trigger Actions](#trigger-actions)
[Back to Actions](#actions-and-conditions)

## Conditional Text Part 2
In the previous chunk, we saw how short text can be inserted into the story. For longer texts (as well as triggers and blockquotes) we can use conditions to decide if they should be displayed.

~~~
But how would I travel to Europe?
<:
  bag_has? "submarine"
::
  Of course! I could travel to Europe by submarine.

  [Travel to Europe by Submarine](#submarine)
:>
~~~

In the example above, if the player does not have a submarine in their bag, they will see only the question: "But how would I travel to Europe?"

If they have the submarine, they see the conditional text:

> But how would I travel to Europe? Of course! I could travel to Europe by submarine.

They will also see a nice new button to help them start their under-sea voyage.

---
[Next: Conditions Part 3](#conditional-text-part-3)
[Back: Conditions Part 1](#conditional-text-part-1)
[Back to Actions](#actions-and-conditions)

## Conditional Text Part 3
You may want to have alternative texts, depending on the result of condition. Say, for example, the player needs the portable submarine to escape the sinking ship. What happens if they don't have it?

In the example below, if the player has the submarine, the block of text following the first `::` will display. If they do not have the submarine, the block of text following the second `::` will display.

~~~
<:
  bag_has? "portable submarine"
::
  I deployed the portable submarine and hopped inside. Bidding adieu to the brave sailors, I set off for Mauritius.
::
  Oh my life! Such bad luck! If only I had a portable submarine! Well, nothing for it but to swim to Mauritius.
:>
~~~

---
[Back: Conditions Part 2](#conditional-text-part-2)
[Back to Actions](#actions-and-conditions)

## Built-in Commands
Forked contains some built-in commands to help you perform some useful or common tasks.

[Commands: Bag (Inventory Management)](#commands-bag-inventory-management)
[Commands: Memo (Information Storage)](#commands-memo-information-storage)
[Commands: Timer (Countdown Timers)](#commands-timer-countdown-timers)
[Commands: Counter (Number Tracking)](#commands-counters-number-tracking)

---
[Next: Examples](#examples)
[Back: Actions](#actions-and-conditions)
[Contents](#contents)

## Commands: Bag (Inventory Management)

The `bag` is where you keep track of the things your player collects during the game. For example, they may pick up a parcel of exotic spices to transport to Europe via submarine. You can add items to the bag like this:

~~~
bag_add "exotic spices"
~~~

Remove items:

~~~
bag_remove "exotic spices"
~~~

And check to see if the player has an item:
~~~
bag_has? "exotic spices"
~~~

If your player is involved in a dramatic shipwreck, they might lose the exotic spices along with everything else in their inventory. You can empty out the bag like this:

~~~
bag_clear
~~~
[See Example](#example-inventory)

---
[Back to Commands](#built-in-commands)

## Commands: Memo (Information Storage)

`memo` is for remembering information like, did the player meet the person of their dreams and fall in love? Did they run away from the evil pastry chef or stand their ground and fight? To remember something:

~~~
memo_add "in love with", "the Dauphine"
~~~

To check a memo:

~~~
memo_check "in love with"
~~~

To forget:

~~~
memo_remove "in love with"
~~~

If your player is hit on the head by a Montgolfier balloon and suffers from total amnesia, this is how to forget everything:
~~~
memo_clear
~~~

---
[Back to Commands](#built-in-commands)

## Commands: Timer (Countdown Timers)

`timer` lets you create a countdown timer. You can check the timer to see if it's done and perform some other action if it is. For example, your player may only have a few seconds to defuse the saboteur's bomb and save the submarine crew:

~~~
timer_add "submarine explosion", 6.seconds"
~~~

To know if a timer has finished and the crew are lost:
~~~
timer_done? "submarine explosion"
~~~

To check how much time is left:

~~~
timer_check "submarine explosion"
~~~

To remove a timer:

~~~
timer_remove "submarine explosion"
~~~

---
[Back to Commands](#built-in-commands)

## Commands: Counters (Number Tracking)

`counter` helps you keep track of the number of times something happens. It may be important in your story that the player gains five exquisite Persian rugs by winning games of croquet. To create a new counter:

~~~
counter_add "number of rugs", 0
~~~
To remove a counter:

~~~
counter_remove "number of rugs"
~~~

To increase or decrease a counter:
~~~
counter_up "number of rugs", 1
counter_down "number of rugs", 2
~~~

And to check how many rugs the player has:

~~~
counter_check "number of rugs"
~~~

---
[Back to Commands](#built-in-commands)


## Examples

[Setting the Display Theme](#example-setting-the-display-theme)
[Countdown Timer](#example-countdown-timer)
[Background Image](#example-background-image)
[Roll Dice](#example-roll-the-dice)
[Inventory](#example-inventory)
[Memorizing Info](#example-memorizing-info)
[Keeping Count](#example-keeping-count)
[Financial Management](#example-financial-management)

---
[Back: Built-in Commands](#built-in-commands)
[Contents](#contents)

## Example: Setting the Display Theme

Change the presentation of the story.

[Turn the lights on](: change_theme(nil) :)
[Turn the lights off](: change_theme DARK_MODE :)
[Turn the lights fun and stupid](: change_theme KIFASS_THEME :)

You can edit the display theme to change the colour scheme. Open the file `app/themes/dark-mode-theme.rb` and you can see how it's done.

---
[Back to Examples](#examples)
[Back to Contents](#contents)

## Example: Countdown Timer
<!-- Check to see if the "oxygen" timer has been created yet
and if it has not, show the button that will create (add) it -->
<:
  !timer_exist? "oxygen"
::
  [Accidentally poke your spacesuit with a screwdriver](: timer_add "oxygen", 10.seconds :)
:>

<!-- If the "oxygen" timer has already been created and is counting down
display another button to stop (remove) the timer -->
<:
  timer_exist? "oxygen"
::
  [Fix the hole in your spacesuit with duct tape](: timer_remove "oxygen" :)
  Warning: space suit rupture detected.
:>

<!-- If the "oxygen" timer exists...
AND if it has finished counting down (done), display a message
if it has not finished counting down, show how many seconds are left -->
<:
  ```rb
  if (timer_exist? "oxygen")
    if (timer_done? "oxygen")
      "Oxygen level: critical! You are feeling very poorly!"
    else
      "Oxygen level: #{timer_seconds "oxygen"}"
    end 
  else
    "Oxygen level: maximum. \nEverything is fine."
  end
  ```
:>

---
[Back to Examples](#examples)
[Back to Contents](#contents)

## Example: Background Image
This example displays a background image behind the story.

The simplest way to do that is to add a conditional block and use the `background_image` command with the path to your image file.

~~~
<: 
background_image "sprites/background.png" 
:>
~~~

<: 
background_image "sprites/background.png" 
:>

---
[Back to Examples](#examples)
[Back to Contents](#contents)

## Example: Image
To display an image within the text of the story:

~~~
![](sprites/blue.png {w: 80, h: 80})
~~~

Replace `sprites/image.png` with the correct path and filename for your image. Forked will display the image at a default size (80px by 80px) so to make the image display at the size you want, you will need to enter the width (`w`) and height (`h`) values.

The image specified above displays like this:

<:
true
::
![](sprites/blue.png {w: 80, h: 80})
:>

---
[Back to Examples](#examples)
[Back to Contents](#contents)


## Example: Roll the Dice
Are you feeling lucky?

The `roll` command lets you add some randomness to your game.

~~~
roll("1d6") # gives the roll of one, six-sided die
roll("2d6") # gives the roll of two, six-sided dice
roll("10d20") # gives the roll of ten, 20-sided dice
~~~
[Try to roll a 6!](: memo_add "roll", roll('1d6') :)

<:
```rb
# use a Ruby case statement to decide how to handle the result
case memo_check "roll" # check the result of the roll
when 6 # handle the different results
  "You did it! You rolled a 6!" # text to display for this result
when 5
  "Ye...oh! You almost got it. You rolled a 5!"
when 4
  "Getting close! You rolled a 4!"
when 3
  "Eh, you rolled a 3."
when 2
  "You're not very good at this. You rolled a 2."
when 1
  "Terrible! You rolled a 1!"
end
```
:>

---
[Back to Examples](#examples)
[Back to Contents](#contents)

## Example: Inventory

Forked gives you a bag to hold the player's inventory.

Your inventory currently contains: 
<: bag_sentence :>

[Pick up the potion of inconsequence](: bag_add "potion of inconsequence" :)
[Pick up the Spear of Astrabliano](: bag_add "Spear of Astrabliano" :)
[Pick up the Golden Crown of Impolior](: bag_add "Golden Crown of Impolior" :)

<: 
  bag_has? "potion of inconsequence" 
::
  [Drink the potion of inconsequence](: bag_remove "potion of inconsequence" :)
:>
<:
  bag_has? "Spear of Astrabliano" 
::
  [Throw the Spear of Astrabliano](: bag_remove "Spear of Astrabliano" :)
:>
<:
  bag_has? "Golden Crown of Impolior" 
::
  [Melt down the Golden Crown of Impolior](: bag_remove "Golden Crown of Impolior" :)
:>

[Turn your bag upside down and shake it out](: bag_clear :)

---
[Back to Examples](#examples)
[Back to Contents](#contents)

## Example: Memorizing info

:: memo_add "favourite colour", "a great mystery" ::

At that time, everyone in European society was speculating about the Dauphine's favourite colour. It was, of course,
<: (memo_check "favourite colour") + '.' :>

[The Dauphine's favourite colour was Moroccan Pink](: memo_add "favourite colour", "Moroccan Pink" :)
[The Dauphine's favourite colour was Cerulean Blue](: memo_add "favourite colour", "Cerulean Blue" :)
[The Dauphine's favourite colour was Etruscan Brown](: memo_add "favourite colour", "Etruscan Brown" :)

---
[Back to Examples](#examples)
[Back to Contents](#contents)

## Example: Keeping Count

`counter` helps you to keep track of simple numbers. How many times did the player press a button? Maybe something different happens each time they press it?

<!-- make a new counter called 'button presses' -->
:: counter_add 'button presses' ::

<!-- the button makes the counter go up by 1 -->
[Press the Big Red Button](: counter_up 'button presses' :)

<!-- display the number of times the button has been pressed -->
Number of button presses:
<: counter_text 'button presses' :>

<!-- this message displays if the number of button presses is 1 or more -->
<:
(counter_check 'button presses') >= 1
::
You press the button and nothing happens. Maybe it's stuck.
:>

<!-- two or more presses -->
<:
(counter_check 'button presses') >= 2
::
You press the button more firmly. It seems to shift a little but without any result.
:>

<!-- three or more -->
<:
(counter_check 'button presses') >= 3
::
You give the button a good slap. You hear a tired whirring sound.
:>

<!-- four or more -->
<:
(counter_check 'button presses') >= 4
::
You ball up your fist and thump the button with all your strength. A small panel whirs opens in the control console and immediately closes, too quickly for you to see what was inside.
:>

<!-- five or more -->
<:
(counter_check 'button presses') >= 5
::
You take the rubber mallet from your backpack and whack the button for all you are worth. The panel opens and stays open. Inside is a small green button labelled "Cancel Nuclear Strike". The button is flashing.

<!-- reset the counter to 0 -->
[Cancel Nuclear Strike](: counter_add 'button presses', 0 :)
:>

---
[Back to Examples](#examples)
[Back to Contents](#contents)

## Example: Financial Management

The `wallet` keeps track of the player's wealth. This is a single number that can be added to and subtracted from as your player picks up or spends dollars, gold coins, gems or whatever currency is used in your game world.

The `wallet` currently contains
<: wallet_text '$' :>

<!-- Add 11 to the wallet when clicked -->
[Earn $11](: wallet_plus 11 :)
<:
```rb
  # check to see if funds are available
  # do we have 7 or more to spend?
  wallet >= 7
```
::
<!-- only show this button if funds are available  -->
<!-- remove 7 from the wallet -->
[Spend $7](: wallet_minus 7 :)
:>

<!-- Empty your wallet out -->
[Clear Wallet](: wallet_clear :)

---
[Back to Examples](#examples)
[Back to Contents](#contents)