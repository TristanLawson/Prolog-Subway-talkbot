/*meal types*/
mealTypeList(["sandwich","combo","other"]).
sandwich(sandwich).
combo(combo).
other(meal).
/*meal options*/
mealOptionList(["healthy","value","vegetarian","vegan","none"]).
healthy(healthy).
value(value).
vegetarian(vegetarian).
/*vegan implies vegetarian*/
vegetarian(Option):-
          vegan(Option).
vegan(vegan).
/*item lists*/
sizes(["sixinch","footlong"]).
breadList(["white","ninegrain","flatbread"]).
proteinList(["ham","chicken","tofu","none"]).
vProteinList(["tofu","none"]).
cheeseList(["cheddar","swiss","parmesan","none"]).
vegList(["lettuce","spinach","tomato","onion","pepper","jalapeno","none"]).
sauceList(["mustard","hotsauce","mayo","none"]).
sideList(["cookie","apple","chips","none"]).
veganSideList(["apple","chips","none"]).
drinkList(["water","milk","coke","applejuice","none"]).
veganDrinkList(["water","coke","applejuice","none"]).
/*healthy option: displays the healthiest item in the list*/
healthiestBread("ninegrain").
healthiestProtein("tofu").
healthiestCheese("none").
healthiestVeg("spinach").
healthiestSauce("none").
healthiestSide("apple").
healthiestDrink("water").
/*healthiest option lookup*/
healthyOption(Option,List):-
          (   healthy(Option),
              (   breadList(List),  healthiestBread(Healthy);
                  proteinList(List),healthiestProtein(Healthy);
                  cheeseList(List), healthiestCheese(Healthy);
                  vegList(List),    healthiestVeg(Healthy);
                  sauceList(List),  healthiestSauce(Healthy);
                  sideList(List),   healthiestSide(Healthy);
                  drinkList(List),  healthiestDrink(Healthy)),
              format("healthiest choice: "),
              write(Healthy),
              format("\n"));
          (   not(healthy(option))).
/*main function, asks user for meal type, meal option.
  Begins their order based on the type and option
   (ex. vegans aren't asked if they want cheese)
  After completing order, proceeds to 'checkout'*/
order():-
          chooseMealType(Type),        %sandwich, combo, other
          chooseMealOption(Option),    %healthy, value, etc.
          (   sandwich(Type),chosen(sauce,Meal,Option);
              combo(Type),chosen(drink,Meal,Type,Option);
              other(Type),chosen(drink,Meal,Type,Option)),
          checkout(Meal,Type,Option).
/*logic path to complete order
  Variables Type and Option are passed to some functions*/
chosen(bread,Meal,Option):-
          chooseBread(Bread,Option),
          append([],Bread,Meal).
chosen(size,Meal,Option):-
          chosen(bread,SMeal,Option),
          chooseSize(Size,Option),
          append(SMeal,Size,Meal).
chosen(protein,Meal,Option):-
          chosen(size,SMeal,Option),
          chooseProtein(Protein,Option),
          append(SMeal,Protein,Meal).
chosen(cheese,Meal,Option):-
          chosen(protein,SMeal,Option),
          chooseCheese(Cheese,Option),
          append(SMeal,Cheese,Meal).
chosen(veg,Meal,Option):-
          chosen(cheese,SMeal,Option),
          chooseVeg(Veg,Option),
          append(SMeal,Veg,Meal).
chosen(sauce,Meal,Option):-
          chosen(veg,SMeal,Option),
          chooseSauce(Sauce,Option),
          append(SMeal,Sauce,Meal).
chosen(side,Meal,Type,Option):-
          (   combo(Type),
              chosen(sauce,SMeal,Option);
              other(Type),
              SMeal = []),
          chooseSide(Side,Option),
          append(SMeal,Side,Meal).
chosen(drink,Meal,Type,Option):-
          chosen(side,SMeal,Type,Option),
          chooseDrink(Drink,Option),
          append(SMeal,Drink,Meal).
/*functions*/
takeout(X,[X|R],R).
takeout(X,[F|R],[F|S]):-takeout(X,R,S).
/*prints list L with space between each element*/
options([]):-format("\n").
options(L):-tab(2),takeout(F,L,SL),write(F),options(SL).
/*User must choose a meal type.*/
chooseMealType(Type):-
          format("What can I get for you today?\n"),
          mealTypeList(L),
          options(L),
          getUserInput(Input,L),
          (   Input = "sandwich",Type = sandwich;
              Input = "combo",   Type = combo;
              Input = "other",   Type = meal).
/*User has the opportunity to choose a meal option.
  vegetarian and vegan remove non-veg/vegan items from the menu
  value gives a discount meal, but with more restrictions
     (such as 6-inch sub, only 1 sauce and veg)
  healthy gives a recommendation about the healthiest choices*/
chooseMealOption(Option):-
          format("Would you like a special meal?\n"),
          mealOptionList(L),
          options(L),
          getUserInput(Input,L),
          (   Input = "healthy",   Option = healthy;
              Input = "value",     Option = value;
              Input = "vegetarian",Option = vegetarian;
              Input = "vegan",     Option = vegan;
              Input = "none",      Option = subway).
/*3 options, user must choose 1*/
chooseBread(Bread,Option):-
          format("Which bread do you want?\n"),
          breadList(L),
          options(L),
          healthyOption(Option,L),
          getUserInput(Choice,L),
          Bread = [Choice].
/*2 sizes, value meal automatically gets 6-inch*/
chooseSize(Size,Option):-
          (   value(Option),Size = ["sixinch"];
              format("What size of bun?\n"),
              sizes(L),
              options(L),
              getUserInput(Choice,L),
              Size = [Choice]).
/*limited choice for vegetarians/vegans*/
chooseProtein(Protein,Option):-
          format("What protein would you like?\n"),
          (   vegetarian(Option),vProteinList(L);
              proteinList(L)),
          options(L),
          healthyOption(Option,L),
          getUserInput(Choice,L),
          Protein = [Choice].
/*skips vegans*/
chooseCheese(Cheese,Option):-
          vegan(Option),Cheese = ["none"];
          format("And would you like some cheese?\n"),
          cheeseList(L),
          options(L),
          healthyOption(Option,L),
          getUserInput(Choice,L),
          Cheese = [Choice].
/*choose as many as you want (except for value meal)*/
chooseVeg(Veg,Option):-
          format("Would you like some vegetables?\n"),
          vegList(L),
          options(L),
          healthyOption(Option,L),
          (   value(Option),
              getUserInput(Choice,L),
              Veg = [Choice];
          getRecursiveInput(Veg,L)).
/*choose as many as you want (again, except for value meal)*/
chooseSauce(Sauce,Option):-
          format("Would you like any sauces?\n"),
          sauceList(L),
          options(L),
          healthyOption(Option,L),
          (   value(Option),
              getUserInput(Choice,L),
              Sauce = [Choice];
          getRecursiveInput(Sauce,L)).
/*choose as many, vegans can't have cookies, value only gets 1*/
chooseSide(Side,Option):-
          format("What sides would you like?\n"),
          (   vegan(Option),
              veganSideList(L);
          sideList(L)),
          options(L),
          healthyOption(Option,L),
          (   value(Option),
              getUserInput(Choice,L),
              Side = [Choice];
           getRecursiveInput(Side,L)).
/*choose 1, vegans can't have milk*/
chooseDrink(Drink,Option):-
          format("Please choose a drink:\n"),
          (   vegan(Option),veganDrinkList(L);
              drinkList(L)),
          options(L),
          healthyOption(Option,L),
          getUserInput(Choice,L),
          Drink = [Choice].
/*display order*/
checkout(Meal,Type,Option):-
          format('Your ~a ~a:\n',[Option,Type]),
          format("---------------\n"),
          (   sandwich(Type),
              printSandwich(Meal,_);
          combo(Type),
              printSandwich(Meal,Other),
              printOther(Other);
          other(Type),
              printOther(Meal)),
          format("---------------\n"),
          format("Thank you for choosing Subway!\n").
/*print sides and drinks unless "none" option*/
printNormal(B):-
          B = "none";
          format('|~a\n',[B]).
/*print toppings with indent unless "none" option*/
printTopping(B):-
          B = "none";
          format('|   ~a\n',[B]).
/*print sandwich type and toppings*/
printSandwich(A,D):-
          A = [B,S|T],
          format('|~a sandwich on ~a\n',[S,B]),
          printSandwichToppings(T,D).
/*recursive function, print all sandwich toppings
  Stops when list is empty or a side/drink appears*/
printSandwichToppings([],[]).
printSandwichToppings(A,D):-
          (   A = [B|C],
              (proteinList(L);cheeseList(L);vegList(L);sauceList(L)),
              member(B,L),
              printTopping(B),
              printSandwichToppings(C,D);
          A = D).
/*print all sides and drinks in the order.
  Stops when the list is empty.*/
printOther([]).
printOther(A):-
          A = [B|C],
          printNormal(B),
          printOther(C).
/*ValidString is a string typed by the user.
  Only returned if it is a member of the list List,
  otherwise it asks again.*/
getUserInput(ValidString,List):-
          read_line_to_string(user_input,String),
          (   member(String,List),ValidString = String;
              format("This is not an option. Please try again:\n"),
              getUserInput(ValidString,List)).
/*Choice is a list of strings ["s1","s2",...]
  It calls recursiveChoice, which asks user for input
  until the user types "none" or is out of options.*/
getRecursiveInput(Choice,L):-
          getUserInput(Input,L),
          (   Input = "none",Choice = ["none"];
          takeout(Input,L,SL),
              recursiveChoice(More,SL),
              append([Input],More,Choice)).
recursiveChoice([],["none"]).
recursiveChoice(Choice,L):-
          format("Would you like any more?\n"),
          options(L),
          getUserInput(Input,L),
          (   Input = "none",Choice = [];
          takeout(Input,L,SL),
              recursiveChoice(More,SL),
              append([Input],More,Choice)).
/*advanced user input:
    accepts a range of inputs for each option
    and has an 'exit' input*/
advancedUserInput(ValidString):-
          read_line_to_string(user_input,S),
          (   member(S,["sandwich","Sandwich","SANDWICH"]),
              ValidString = "sandwich";
          member(S,["combo","Combo","COMBO"]),
              ValidString = "combo";
          member(S,["other","Other","OTHER"]),
              ValidString = "other";
          member(S,["x","X"]),
              ValidString = "X";
          format("This is not an option. Please try again: (type 'X' to exit)\n"),
              advancedUserInput(ValidString)).


