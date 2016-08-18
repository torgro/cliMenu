# Building interactive Menus in Powershell

This is a Controller module. It uses Write-Host to create a Menu in the console. As the name implies
it builds a CLI menu, however if you think your users might fancy a more GUI like experience, you
should look up a cmdlet named Show-Command. Show-Command will build a GUI for you cmdlet. It will
create a windows form with fields for all your parameters and parametersets.


## Design goals

I have seen to many crappy menus that is a mixture of controller script and business logic. It is in 
essence a wild west out there, hence my ultimate goal is to create something that makes it as easy 
as possible to create a menu and change the way it looks. 

1. Make it easy to build Menus and change them
2. Make it as "declarative" as possible


## Menus

The module supports multiple Menus, however only one Main-Menu. Each menu has a collection of Menu-
Items that the user can choose from. 

Example menu:
[ExamleMenu]: https://github.com/torgro/cliMenu/blob/master/Bin/cliMenu.png 
![alt text][ExamleMenu]


## Menu options

Currently you can control the following aspects of the menu (they are shared across all menus unless you change
them before showing a sub-menu):

* Choose the char that creates the outer frame of the menu
* Change the color of the frame
* Change the Color and DisplayName for the Menus
* Change the color and Heading for the Menus
* Change the color and Sub-Heading for the Menus
* Change the color and DisplayName for the Menu-Items
* Change the color and footer text for the menus
* Change the Width of the Menu


## Menu-Items

Menu-Items are the elements your users can invoke in your Menu. They have a ScriptBlock and a DisableConfirm 
switch parameter in addition to a Name and DisplayName. With the DisableConfirm parameter, you may selectively 
force the user to confirm the action before it is invoked.


## Validation and return values

The goal of this module is neither. As a toolbuilder you are responsible for validating user
input when they invoke the ScriptBlock assosiated with the Menu-Item. Any output from the ScriptBlock 
will be written in the console. As you may know, a ScriptBlock may be a small script or a call to 
a cmdlet with parameters. I would suggest that you stick to calling custom or built-in cmdlets and 
design it using the best practice guides from Microsoft in regards to mandatory parameters etc.


## Show-Menu

This is the core cmdlet responsible for building the Menu and displaying it to the user. Executed
without parameters it will display the Main-Menu (remember you can only have one Main-Menu). Nevertheless
you may also use it to display Sub-Menus by specifying the parameter MenuId which is the index of the
menu. Further you may also invoke a specific Menu-Item in a specific Menu by supplying InvokeItem and MenuId
parameters. If the Menu-Item is defined to confirm with the user before invocation, it will prompt the user
with a confirmation request before execution. You can override this with the -Force parameter to execute it
directly.

## Examples

A menu which uses the Show-Command cmdlet (complete script in [example.ps1](https://github.com/torgro/cliMenu/blob/master/Scripts/Example.ps1)):
[Example1]: https://github.com/torgro/cliMenu/blob/master/Bin/Example1.png 

```powershell
Import-Module .\CliMenu.psd1

Set-MenuOption -Heading "Helpdesk Inteface System" -SubHeading "LOIS by Firstpoint" -MenuFillChar "#" -MenuFillColor DarkYellow
Set-MenuOption -HeadingColor DarkCyan -MenuNameColor DarkGray -SubHeadingColor Green -FooterTextColor DarkGray
Set-MenuOption -MaxWith 60

$newItem1 = @{
    Name = "WriteHost"
    DisplayName = "Launch Write-Host as a GUI"
    Action = { show-command -Name Write-host }
    DisableConfirm = $true
}

$newMenu = @{
    Name = "Main"
    DisplayName = "Main Menu"
}

# Create a new menu Item
$menuItem = New-MenuItem @newItem1

# Create a new menu (first menu will become the main menu)
$mainMenu = New-Menu @newMenu

# Add menu item to the menu named 'main'
$menuItem | Add-MenuItem -Menu main
Clear-Host
Show-Menu
```
![alt text][Example1]

An example with a Main-Menu and Sub-Menu:
[Example21]: https://github.com/torgro/cliMenu/blob/master/Bin/Example21.png
[Example22]: https://github.com/torgro/cliMenu/blob/master/Bin/Example22.png 

```powershell
Import-Module .\CliMenu.psd1

Set-MenuOption -Heading "Helpdesk Inteface System" -SubHeading "LOIS by Firstpoint" -MenuFillChar "#" -MenuFillColor DarkYellow
Set-MenuOption -HeadingColor DarkCyan -MenuNameColor DarkGray -SubHeadingColor Green -FooterTextColor DarkGray
Set-MenuOption -MaxWith 60

$newItem1 = @{
    Name = "WriteHost"
    DisplayName = "Launch Write-Host as a GUI"
    Action = { show-command -Name Write-host }
    DisableConfirm = $true
}

$newMenu = @{
    Name = "Main"
    DisplayName = "Main Menu"
}

# Create a new menu Item
$menuItem = New-MenuItem @newItem1

# Create a new menu (first menu will become the main menu)
$mainMenu = New-Menu @newMenu

# Add menu item to the menu named 'main'
$menuItem | Add-MenuItem -Menu main

$newItem2 = @{
    Name = "GoToSub"
    DisplayName = "Go to submenu"
    Action = { Show-Menu -MenuName SubMenu }
}

# Add a menuitem to the main menu
$mainMenu | New-MenuItem @newItem2 -DisableConfirm

$newItemSubMenu = @{
    Name = "GoToMain"
    DisplayName = "Go to Main Menu"
    Action = { Show-Menu }
}

# Create a new menu (sub-menu) and add a menu-item to it
New-Menu -Name SubMenu -DisplayName "*** SubMenu1 ***" | New-MenuItem @newItemSubMenu -DisableConfirm

clear-host
Show-Menu
```

![alt text][Example21]

![alt text][Example22]

That is it. If you have any questions or issues, look me up on twitter (@toreGroneng) or file an issue!

### Credits

Big thank you to Fausto Nascimento for invaluable input and suggestions!

### Disclaimer

THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
