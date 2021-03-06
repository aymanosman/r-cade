#lang scribble/manual

@require[@for-label[r-cade]]

@title{R-cade Game Engine}
@author[@author+email["Jeffrey Massung" "massung@gmail.com"]]

@defmodule[r-cade]

R-cade is a simple, retro game engine for Racket.


@;; ----------------------------------------------------
@section{Homepage}

All the most recent updates, blog posts, etc. can be found at @url{http://r-cade.io}.


@;; ----------------------------------------------------
@section{Core}

@defproc[(run [game-loop procedure?]
              [width exact-nonnegative-integer?]
              [height exact-nonnegative-integer?]
              [#:init init procedure? #f]
              [#:scale scale-factor exact-nonnegative-integer? #f]
              [#:fps frame-rate exact-nonnegative-integer? 60]
              [#:shader crt-effect boolean? #t]
              [#:title window-title string? "R-cade"])
         void?]{
Creates a new game window, video memory, and enters the main game loop.

The @racket[game-loop] parameter is a function you provide, which will be called once per frame and should take no arguments.

The @racket[width] and @racket[height] parameters define the size of video memory (not the size of the window!).

The @racket[init] procedure - if provided - is called before the @racket[game-loop] starts.

The @racket[scale-factor] parameter will determine the initial size of the window. The default will let auto pick a scale factor that is appropriate given the size of the display.

The @racket[frame-rate] is the number of times per second the @racket[game-loop] function will be called the window will update with what's stored in VRAM.

The @racket[crt-effect] controls whether or not the contents of VRAM are rendered using a fullscreen shader effect that mimics a CRT. If this is set to @racket[#f] the effect will be disabled.

The @racket[window-title] parameter is the title given to the window created.
}


@;; ----------------------------------------------------
@defproc[(quit) void?]{Closes the window, which will terminate the main game loop.}


@;; ----------------------------------------------------
@defproc[(wait [until procedure? btn-any]) void?]{Hard stops the game loop and waits until either the window is closed or the until function returns true. While waiting, events are still processed.}


@;; ----------------------------------------------------
@defproc[(sync) void?]{Called once per frame automatically by the main game loop. You shouldn’t need to call this yourself unless you are creating your own game loop. It processes all events, renders video memory, and ensures the framerate is locked.}


@;; ----------------------------------------------------
@defproc[(frame) exact-nonnegative-integer?]{Returns the current frame: 1, 2, 3, ...}


@;; ----------------------------------------------------
@defproc[(frametime) real?]{Returns the delta time (in seconds) since the last frame. It’s best to use this when applying any kind of velocity to a game object instead of assuming the framerate will be constant.}


@;; ----------------------------------------------------
@defproc[(gametime) real?]{Returns the total time (in seconds) since the game started.}


@;; ----------------------------------------------------
@defproc[(width) exact-nonnegative-integer?]{Returns the width of VRAM in pixels. This is the same value that was passed to the @racket[run] function.}


@;; ----------------------------------------------------
@defproc[(height) exact-nonnegative-integer?]{Returns the height of VRAM in pixels. This is the same value that was passed to the @racket[run] function.}


@;; ----------------------------------------------------
@section{Input}


All @tt{btn-*} functions return @racket[#f] if their respective button is not pressed, otherwise they return the count of how many frames the button has been pressed for. For example, a return value of @tt{1} would indicate the button was just pressed. This allows for easy testing of not pressed, pressed, just pressed, or against a desired repeat rate.


@;; ----------------------------------------------------
@defproc[(btn-start) (or #f exact-nonnegative-integer?)]{Returns the state of the ENTER key.}


@;; ----------------------------------------------------
@defproc[(btn-select) (or #f exact-nonnegative-integer?)]{Returns the state of the SPACEBAR key.}


@;; ----------------------------------------------------
@defproc[(btn-quit) (or #f exact-nonnegative-integer?)]{Returns the state of the ESCAPE key.}


@;; ----------------------------------------------------
@defproc[(btn-z) (or #f exact-nonnegative-integer?)]{Returns the state of the Z key.}


@;; ----------------------------------------------------
@defproc[(btn-x) (or #f exact-nonnegative-integer?)]{Returns the state of the X key.}


@;; ----------------------------------------------------
@defproc[(btn-up) (or #f exact-nonnegative-integer?)]{Returns the state of the UP arrow key.}


@;; ----------------------------------------------------
@defproc[(btn-down) (or #f exact-nonnegative-integer?)]{Returns the state of the DOWN arrow key.}


@;; ----------------------------------------------------
@defproc[(btn-right) (or #f exact-nonnegative-integer?)]{Returns the state of the RIGHT arrow key.}


@;; ----------------------------------------------------
@defproc[(btn-left) (or #f exact-nonnegative-integer?)]{Returns the state of the LEFT arrow key.}


@;; ----------------------------------------------------
@defproc[(btn-mouse) (or #f exact-nonnegative-integer?)]{Returns the state of the LEFT mouse button.}


@;; ----------------------------------------------------
@defproc[(btn-any) boolean?]{Returns the equivelant of:
 @racketblock[(or (btn-start)
                  (btn-select)
                  (btn-quit)
                  (btn-z)
                  (btn-x))]}

This function isn't really used much outside of @racket[wait].


@;; ----------------------------------------------------
@defproc[(mouse-x) exact-nonnegative-integer?]{Returns the X pixel (in VRAM) that the mouse is over. @tt{0} is the left edge.}


@;; ----------------------------------------------------
@defproc[(mouse-y) exact-nonnegative-integer?]{Returns the Y pixel (in VRAM) that the mouse is over. @tt{0} is the top edge.}


@;; ----------------------------------------------------
@section{Action Bindings}

Sometimes you want to be able to bind buttons to specific, named actions so your
code is easier to read (and modify if you want to change your button mapping). To
do this, use the @racket[define-action] macro.


@;; ----------------------------------------------------
@defform/subs[(define-action name btn [rate #f])
              ([name symbol?]
               [btn procedure?]
               [rate (or #t exact-nonnegative-integer?)])]{
Defines a new function @racket[name] that returns @racket[#t] if the mapped @racket[btn] binding predicate function should be considered "pressed".

If @racket[rate] is @racket[#f] (the default), then the action is defined as @racket[(define name btn)].

If @racket[rate] is @racket[#t] then the action will return @racket[#t] if the @racket[btn] returns @tt{1}, indicating it was just pressed this frame.

Othweise, @racket[rate] should be a non-negative integer indicating how many times per seconds the action function should return @racket[#t] assuming the button is held down. This is useful for actions like shooting that shouldn't happen every frame, but you also don't want the user to have to keep pressing the input button.

@racketblock[
 (define-action move-left btn-left)
 (define-action jump btn-z #t)
 (define-action fire btn-x 5)
]}


@;; ----------------------------------------------------
@section{Drawing}


@;; ----------------------------------------------------
@defproc[(cls [c exact-nonnegative-integer? 0]) void?]{Clears video memory with the specified color. Remember that video memory isn’t magically wiped each frame.}


@;; ----------------------------------------------------
@defproc[(color [c exact-nonnegative-integer?]) void?]{Changes the active color to @racket[c] (0-15). The default color palette is the same as the PICO-8:

 @image["scribblings/palette.png"]}


@;; ----------------------------------------------------
@defproc[(set-color! [c exact-nonnegative-integer?]
                     [r byte?]
                     [g byte?]
                     [b byte?]) void?]{
Changes the color in the palette at index @racket[c] to the RGB byte values specified by @racket[r], @racket[g], and @racket[b].}


@;; ----------------------------------------------------
@defproc[(draw [x real?] [y real?] [sprite (listof byte?)]) void?]{
Uses the current color to render a 1-bit sprite composed of bytes to VRAM at (@racket[x],@racket[y]). For example:

@code[]{(draw 10 12 '(#b01000000 #b11100000 #b01000000))}

The above would draw a 3x3 sprite that looks like a + sign to the pixels at (10,12) -> (12,14). Any bit set in the sprite pattern will change the pixel color in VRAM to the current color. Any cleared bits are skipped.

@italic{Remember! The most significant bit of each byte is drawn at @racket[x]. This is important, because if you'd like to draw a single pixel at (@racket[x],@racket[y]), you need to draw @tt{#b10000000} and not @tt{#b00000001}!}
}


@;; ----------------------------------------------------
@defproc[(text [x real?] [y real?] [s any]) void?]{Draw the value @racket[s] at (@racket[x],@racket[y]) using the current font. The default font is a fixed-width, ASCII font with character range [@tt{#x20},@tt{#x7f}]. Each character is 3x6 pixels in size.}


@;; ----------------------------------------------------
@defproc[(line [x1 real?] [y1 real?] [x2 real?] [y2 real?]) void?]{Draw a line from (@racket[x1],@racket[y1]) to (@racket[x2],@racket[y2]) using the current color.}


@;; ----------------------------------------------------
@defproc[(rect [x real?]
               [y real?]
               [w real?]
               [h real?]
               [#:fill boolean? #f])
         void?]{
Draw a rectangle starting at (@racket[x],@racket[y]) with a width @racket[w] and height @racket[h] using the current color. If @racket[fill] is @racket[#t] then it will be a solid rectangle, otherwise just the outline.
}


@;; ----------------------------------------------------
@defproc[(circle [x real?] [y real?] [r real?] [#:fill boolean? #f]) void?]{
Draw a circle with its center at (@racket[x],@racket[y]) and radius @racket[r] using the current color. If @racket[fill] is @racket[#t] then it will be solid, otherwise just the outline.
}


@;; ----------------------------------------------------
@section{Sound}

All audio is played by composing 8-bit PCM WAV data.


@;; ----------------------------------------------------
@defproc[(sound [curve procedure?]
                [seconds real?]
                [#:instrument wave-function procedure? sin]
                [#:envelope envelope procedure? (const 1)]) sound?]{
All sounds are made using the sound function. The @racket[curve] argument is a function that is given a single value in the range of [@tt{0.0}, @tt{1.0}] and should return a frequency to play at that time; @tt{0.0} is the beginning of the waveform and @tt{1.0} is the end. The seconds parameter defines the length of the waveform.

The @racket[#:instrument] is the wave function to use and defaults to a simple sine wave. Some pre-defined wave functions include:

@itemlist[
 @item{@racket[sawtooth-wave]}
 @item{@racket[square-wave]}
 @item{@racket[triangle-wave]}
 @item{@racket[noise-wave]}
]

You can also define your own wave functions. It should take a single argument in the range of [@tt{0.0}, @tt{2π}] and the return value should be in the range of [@tt{-1.0}, @tt{1.0}].

The @racket[#:envelope] is an amplitude multiplier. It is a function which - like @racket[curve] - is given a single value in the range [@tt{0.0}, @tt{1.0}] indicating where in the sound it is. It should return a value in the range [@tt{0.0}, @tt{1.0}], where @tt{0.0} indicates a null amplitude and @tt{1.0} indicates full amplitude. The default is to simply play the entire sound at full amplitude. Some pre-defined envelopes include:

@itemlist[
 @item{@racket[fade-in-envelope]}
 @item{@racket[fade-out-envelope]}
 @item{@racket[z-envelope]}
 @item{@racket[s-envelope]}
]

There is also an @racket[envelope] function that helps with the creation of your own envelopes.
}


@;; ----------------------------------------------------
@defproc[(envelope [y real?] ...) procedure?]{Returns a function that can be used as the @racket[#:envelope] paramater to the @racket[sound] function. It builds a simple, evenly spaced, linearly interpolated plot of amplitude envelopes. For example, the @racket[z-envelope] is defined as:

@racketblock[(define z-envelope (envelope 1 1 0 0))]

This means that in the time range of [@tt{0.0}, @racket[0.33]] the sound will play at full amplitude. From [@racket[0.33], @racket[0.66]] the envelope will decay the amplitude linearly from @tt{1.0} down to @tt{0.0}. Finally, from [@racket[0.66], @tt{1.0}] the amplitude of the sound will be forced to @tt{0.0}.
}


@;; ----------------------------------------------------
@defproc[(tone [freq real?]
               [seconds real?]
               [#:instrument wave-function procedure? sin]
               [#:envelope envelope procedure? (const 1)]) sound?]{
This is a simple helper function for generating sounds of a constant frequency for a period of @racket[seconds]. See @racket[sound].
}


@;; ----------------------------------------------------
@defproc[(sweep [start-freq real?]
                [end-freq real?]
                [seconds real?]
                [#:instrument wave-function procedure? sin]
                [#:envelope envelope procedure? (const 1)]) sound?]{
This is a simple helper function for generating a sound that linearly interpolates its frequency from @racket[start-freq] to @racket[end-freq] over a period of @racket[seconds]. See @racket[sound].
}


@;; ----------------------------------------------------
@defthing[square-wave procedure?]{A wave function that may be passed as an @racket[#:instrument].}


@;; ----------------------------------------------------
@defthing[triangle-wave procedure?]{A wave function that may be passed as an @racket[#:instrument].}


@;; ----------------------------------------------------
@defthing[sawtooth-wave procedure?]{A wave function that may be passed as an @racket[#:instrument].}


@;; ----------------------------------------------------
@defthing[noise-wave procedure?]{A wave function that may be passed as an @racket[#:instrument].}


@;; ----------------------------------------------------
@defthing[fade-in-envelope procedure? #:value (envelope 0 1)]{An envelope function that may be passed as an @racket[#:envelope].}


@;; ----------------------------------------------------
@defthing[fade-out-envelope procedure? #:value (envelope 1 0)]{An envelope function that may be passed as an @racket[#:envelope].}


@;; ----------------------------------------------------
@defthing[z-envelope procedure? #:value (envelope 1 1 0 0)]{An envelope function that may be passed as an @racket[#:envelope].}


@;; ----------------------------------------------------
@defthing[s-envelope procedure? #:value (envelope 0 0 1 1)]{An envelope function that may be passed as an @racket[#:envelope].}


@;; ----------------------------------------------------
@defproc[(sound? [x any]) boolean?]{Returns @racket[#t] if @racket[x] is a sound object.}


@;; ----------------------------------------------------
@defproc[(play-sound [sound sound?]
                     [#:volume volume real? 100.0]
                     [#:pitch pitch real? 1.0]
                     [#:loop loop boolean? #f]) channel?]{
Uses one of 4 sound channels to play the sound. If no channels are available then the sound will not be played. Returns the sound channel it is playing on or @racket[#f].
}


@;; ----------------------------------------------------
@defproc[(stop-sound [channel channel?]) void?]{Stops the sound currently playing on the @racket[channel] specified.}


@;; ----------------------------------------------------
@defproc[(channel? [x any]) boolean?]{Returns @racket[#t] if @racket[x] is a channel object.}


@;; ----------------------------------------------------
@section{Music}

Music is created by parsing notes and creating an individual waveform for each note, then combining them together into a single waveform to be played on a dedicated music channel. Only one "tune" can be playing at a time.


@;; ----------------------------------------------------
@defproc[(music [notes string?]
                [#:bpm beats-per-minute exact-nonnegative-integer? 160]
                [#:instrument wave-function procedure? sin]) music?]{
Parses the @racket[notes] string and builds a waveform for each note. Notes are in the format @tt{<key>[<octave>][<hold>]}. For example:

@itemlist[
 @item{@racket["C#3--"] is a C-sharp in 3rd octave and held for a total of 3 quarter-notes time;}
 @item{@racket["Bb"] is a B-flat held for a single quarter-note and uses the octave of whatever note preceeded it;}
]

The default octave is 4, but once an octave is specified for a note then that becomes the new default octave for subsequent notes.

How long each note is held for (in seconds) is determined by the @racket[#:bpm] (beats per minute) parameter. A single beat is assumed to be a single quarter-note. So, with a little math, a @tt{"C#--"} at a rate of 160 BPM would play for 1.125 seconds (3 beats * 60 s/m ÷ 160 bpm). It is not possible to specify 1/8th and 1/16th notes. In order to achieve them, increase the @racket[#:bpm] appropriately.

All note waveforms are played with an ADSR (attack, decay, sustain, release) envelope. This cannot be overridden.
}


@;; ----------------------------------------------------
@defproc[(music? [x any]) boolean?]{Returns @racket[#t] if @racket[x] is a music object.}


@;; ----------------------------------------------------
@defproc[(play-music [tune music?]
                     [#:volume volume real? 100.0]
                     [#:pitch pitch real? 1.0]
                     [#:loop loop boolean? #t]) void?]{
Stops any music currently playing and starts playing @racket[tune]. The@racket[volume], @racket[pitch], and @racket[loop] parameters are the same as those of the @racket[play-sound] function.
}


@;; ----------------------------------------------------
@defproc[(stop-music) void?]{Stops any music currently playing.}


@;; ----------------------------------------------------
@defproc[(pause-music [pause boolean? #t]) void?]{If pause is @racket[#t] then the currently playing music is paused, otherwise it is resumed. If the music was not already pausedy and is told to resume, it will instead restart from the beginning.}
