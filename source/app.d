import std.stdio;
import std.regex;
import std.format;
import std.process;
import std.path;
import std.file;
import core.stdc.stdlib;
import std.uuid;

string makeConfig()
{
    return
`{
    "name": "temp",
    "targetName": "temp",
    "targetType": "executable"
}`;
}

string makeSourceCode(string input)
{
    return format(
`
void main()
{
    %s
}`, input);
}

void main()
{
    string input;
    foreach (line; stdin.byLine)
        input ~= line;

    // create dub root dir
    auto evalDir = buildPath(tempDir(), "evald-%s/".format(randomUUID()));
    mkdirRecurse(evalDir);

    // create dub.json
    {
        scope dubJsonFile = File(buildPath(evalDir, "dub.json"), "w");
        dubJsonFile.write(makeConfig());
    }

    // create source/app.d
    {
        scope sourceDir = buildPath(evalDir, "source");
        mkdir(sourceDir);
        scope sourceFile = File(buildPath(sourceDir, "app.d"), "w");
        sourceFile.write(makeSourceCode(input));
    }

    // chdir and execute
    chdir(evalDir);
    auto dub = execute(["dub", "run"]);
    dub.output.write;

    exit(dub.status);
}
