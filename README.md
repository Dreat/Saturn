# Saturn

```
Saturn (Latin: Sāturnus [saːˈtʊrnʊs]) was a god in ancient Roman religion, and a character in Roman mythology. He was described as a god of time, generation, dissolution, abundance, wealth, agriculture, periodic renewal and liberation.
```

## Running app

To start app:

* Run `mix setup` to install and setup dependencies
* Run `mix test`
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


## Assumptions

- mass can be only integers
- equipment and fuel is in kgs
- persistence layer was skipped for brevity, but would be expected in "full project"
- destinations can be added in random order

## Technical details

Backend:
- module `Fuel` is responsible for all maths, it's unit tested
- module `Gravity` is basically a bag for constants. No tests needed unless module grows with logic.
- I used `Decimal` package for proper handling of calculation involving fractions
- I did rudimentary `typespec` for method in backend as usual good practice

Frontend:
- all happens inside `mission_control.ex`
- simple UI that allows adding, editing and removing destinations
- UI handles invalid states with grace, not relying only on frontend validation, but provides it as quality of life for user
- has LiveView test suite
- with persistence, using destination ids would make creating extensive test suite easier and also remove warnings in JS console
- because `render` is quite small and compact, I decided to leave it in main file. Usually I move it to separate file if it grows too much
- `render_destination` seems like a good candidate for a `LiveComponent`, but I'd only extract it there if:
  1. More views would use it
  2. It would grown significantly


## Possible improvements/future development

- better handling of destination id - either introduce persistance, keep state in separate process and/or in URL params. This is to make further development, maintenance and bugfixing easier.
- optional forcing of specified order of travel
- having most common spacecraft masses available from UI
- option to calculate how much cargo can be taken without need of increasing fuel amount
- a touch of UX designer ;)
