g_PluginInfo =
{
	Name = "Weapons",
	Version = "1.1.1",
	Date = "2017-05-17",
	SourceLocation = "https://github.com/mathiascode/Weapons",
	Description = [[Plugin that adds weapons to a Cuberite server. Currently available weapons are Anvil Dropper, Lightning Stick, Nuker and Sniper.]],

	Commands =
	{
		["/weapons"] =
		{
			Alias = "/weapon",
			Handler = HandleWeaponsCommand,
			Permission = "weapons.weapons",
			HelpString = "Gives you a weapon"
		},

	},
}
