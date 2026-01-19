{
  description = "A collection of flake templates";

  outputs =
    { self }:
    {
      templates = {
        crane = {
          path = ./crane;
          description = "A full rust template with crane";
        };

        simple = {
          path = ./simple;
          description = "A simple rust template without package building";
        };
      };
    };
}
