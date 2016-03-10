within ClaRa.Components.Utilities.Blocks;
model TableGain "Table based gain"
//___________________________________________________________________________//
// Component of the ClaRa library, version: 1.1.0                        //
//                                                                           //
// Licensed by the DYNCAP/DYNSTART research team under Modelica License 2.   //
// Copyright � 2013-2016, DYNCAP/DYNSTART research team.                     //
//___________________________________________________________________________//
// DYNCAP and DYNSTART are research projects supported by the German Federal //
// Ministry of Economic Affairs and Energy (FKZ 03ET2009/FKZ 03ET7060).      //
// The research team consists of the following project partners:             //
// Institute of Energy Systems (Hamburg University of Technology),           //
// Institute of Thermo-Fluid Dynamics (Hamburg University of Technology),    //
// TLK-Thermo GmbH (Braunschweig, Germany),                                  //
// XRG Simulation GmbH (Hamburg, Germany).                                   //
//___________________________________________________________________________//

  import Modelica.Blocks.Types;
  parameter Boolean tableOnFile=false "true, if table is defined on file or in function usertab"
    annotation(Dialog(group="table data definition"));
  parameter Real table[:, :]=fill(0.0,0,2) "table matrix (grid = first column; e.g., table=[0,2])"
       annotation(Dialog(group="table data definition", enable = not tableOnFile));
  parameter String tableName="NoName" "table name on file or in function usertab (see docu)"
       annotation(Dialog(group="table data definition", enable = tableOnFile));
  parameter String fileName="NoName" "file where matrix is stored"
       annotation(Dialog(group="table data definition", enable = tableOnFile,
                         __Dymola_loadSelector(filter="Text files (*.txt);;Matlab files (*.mat)",
                         caption="Open file in which table is present")));
  parameter Integer columns[:]=2:size(table, 2) "columns of table to be interpolated"
  annotation(Dialog(group="table data interpretation"));
  parameter Modelica.Blocks.Types.Smoothness smoothness=Types.Smoothness.LinearSegments "smoothness of table interpolation"
  annotation(Dialog(group="table data interpretation"));
  extends Modelica.Blocks.Interfaces.MIMOs(final n=size(columns, 1));

  parameter Boolean divide = false "True if y = u/table(u)";
protected
  Integer tableID;

  function tableInit "Initialize 1-dim. table defined by matrix (for details see: Modelica/Resources/C-Sources/ModelicaTables.h)"
    input String tableName;
    input String fileName;
    input Real table[ :, :];
    input Modelica.Blocks.Types.Smoothness smoothness;
    output Integer tableID;
  external "C" tableID=  ModelicaTables_CombiTable1D_init(
                 tableName, fileName, table, size(table, 1), size(table, 2),
                 smoothness);
    annotation(Library="ModelicaExternalC");
  end tableInit;

  function tableIpo "Interpolate 1-dim. table defined by matrix (for details see: Modelica/Resources/C-Sources/ModelicaTables.h)"
    input Integer tableID;
    input Integer icol;
    input Real u;
    output Real value;
  external "C" value =
                     ModelicaTables_CombiTable1D_interpolate(tableID, icol, u);
    annotation(Library="ModelicaExternalC");
  end tableIpo;
equation
  if tableOnFile then
    assert(tableName<>"NoName", "tableOnFile = true and no table name given");
  end if;
  if not tableOnFile then
    assert(size(table,1) > 0 and size(table,2) > 0, "tableOnFile = false and parameter table is an empty matrix");
  end if;

  for i in 1:n loop
    y[i] = if divide then u[i]/(if not tableOnFile and size(table,1)==1 then
             table[1, columns[i]] else tableIpo(tableID, columns[i], u[i])) else u[i]*(if not tableOnFile and size(table,1)==1 then
             table[1, columns[i]] else tableIpo(tableID, columns[i], u[i]));
  end for;
  when initial() then
    tableID=tableInit(if tableOnFile then tableName else "NoName",
                      if tableOnFile then fileName else "NoName", table, smoothness);
  end when;
  annotation (
    Documentation(info="<html>
<p>
<b>Linear interpolation</b> in <b>one</b> dimension of a <b>table</b>.
Via parameter <b>columns</b> it can be defined how many columns of the
table are interpolated. If, e.g., columns={2,4}, it is assumed that 2 input
and 2 output signals are present and that the first output interpolates
the first input via column 2 and the second output interpolates the
second input via column 4 of the table matrix.
</p>
<p>
The grid points and function values are stored in a matrix \"table[i,j]\",
where the first column \"table[:,1]\" contains the grid points and the
other columns contain the data to be interpolated. Example:
</p>
<pre>
   table = [0,  0;
            1,  1;
            2,  4;
            4, 16]
   If, e.g., the input u = 1.0, the output y =  1.0,
       e.g., the input u = 1.5, the output y =  2.5,
       e.g., the input u = 2.0, the output y =  4.0,
       e.g., the input u =-1.0, the output y = -1.0 (i.e., extrapolation).
</pre>
<ul>
<li> The interpolation is <b>efficient</b>, because a search for a new interpolation
     starts at the interval used in the last call.</li>
<li> If the table has only <b>one row</b>, the table value is returned,
     independent of the value of the input signal.</li>
<li> If the input signal <b>u[i]</b> is <b>outside</b> of the defined <b>interval</b>, i.e.,
     u[i] &gt; table[size(table,1),i+1] or u[i] &lt; table[1,1], the corresponding
     value is also determined by linear
     interpolation through the last or first two points of the table.</li>
<li> The grid values (first column) have to be <b>strict</b>
     monotonically increasing.</li>
</ul>
<p>
The table matrix can be defined in the following ways:
</p>
<ol>
<li> Explicitly supplied as <b>parameter matrix</b> \"table\",
     and the other parameters have the following values:
<pre>
   tableName is \"NoName\" or has only blanks,
   fileName  is \"NoName\" or has only blanks.
</pre></li>
<li> <b>Read</b> from a <b>file</b> \"fileName\" where the matrix is stored as
      \"tableName\". Both ASCII and binary file format is possible.
      (the ASCII format is described below).
      It is most convenient to generate the binary file from Matlab
      (Matlab 4 storage format), e.g., by command
<pre>
   save tables.mat tab1 tab2 tab3 -V4
</pre>
      when the three tables tab1, tab2, tab3 should be
      used from the model.</li>
<li>  Statically stored in function \"usertab\" in file \"usertab.c\".
      The matrix is identified by \"tableName\". Parameter
      fileName = \"NoName\" or has only blanks.</li>
</ol>
<p>
Table definition methods (1) and (3) do <b>not</b> allocate dynamic memory,
and do not access files, whereas method (2) does. Therefore (1) and (3)
are suited for hardware-in-the-loop simulation (e.g., with dSpace hardware).
When the constant \"NO_FILE\" is defined in \"usertab.c\", all parts of the
source code of method (2) are removed by the C-preprocessor, such that
no dynamic memory allocation and no access to files takes place.
</p>
<p>
If tables are read from an ASCII-file, the file need to have the
following structure (\"-----\" is not part of the file content):
</p>
<pre>
-----------------------------------------------------
#1
double tab1(5,2)   # comment line
  0   0
  1   1
  2   4
  3   9
  4  16
double tab2(5,2)   # another comment line
  0   0
  2   2
  4   8
  6  18
  8  32
-----------------------------------------------------
</pre>
<p>
Note, that the first two characters in the file need to be
\"#1\". Afterwards, the corresponding matrix has to be declared
with type, name and actual dimensions. Finally, in successive
rows of the file, the elements of the matrix have to be given.
Several matrices may be defined one after another.
</p>
</HTML>
"), Icon(coordinateSystem(preserveAspectRatio=true, extent={{-100,-100},{100,100}}),
                    graphics={
        Line(points={{-60,40},{-60,-40},{60,-40},{60,40},{30,40},{30,-40},{-30,
              -40},{-30,40},{-60,40},{-60,20},{60,20},{60,0},{-60,0},{-60,-20},
              {60,-20},{60,-40},{-60,-40},{-60,40},{60,40},{60,-40}}, color={
              0,0,0}),
        Line(points={{0,40},{0,-40}}, color={0,0,0}),
        Rectangle(
          extent={{-60,40},{-30,20}},
          lineColor={0,0,0},
          fillColor={255,255,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-60,20},{-30,0}},
          lineColor={0,0,0},
          fillColor={255,255,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-60,0},{-30,-20}},
          lineColor={0,0,0},
          fillColor={255,255,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-60,-20},{-30,-40}},
          lineColor={0,0,0},
          fillColor={255,255,0},
          fillPattern=FillPattern.Solid),
        Polygon(
          points={{-60,40},{60,0},{-60,-40},{-60,40}},
          lineColor={1,48,118},
          smooth=Smooth.None)}),
    Diagram(coordinateSystem(preserveAspectRatio=true, extent={{-100,-100},{
            100,100}}), graphics={
        Rectangle(
          extent={{-60,60},{60,-60}},
          fillColor={235,235,235},
          fillPattern=FillPattern.Solid,
          lineColor={0,0,255}),
        Line(points={{-100,0},{-58,0}}, color={0,0,255}),
        Line(points={{60,0},{100,0}}, color={0,0,255}),
        Text(
          extent={{-100,100},{100,64}},
          textString="1 dimensional linear table interpolation",
          lineColor={0,0,255}),
        Line(points={{-54,40},{-54,-40},{54,-40},{54,40},{28,40},{28,-40},{-28,
              -40},{-28,40},{-54,40},{-54,20},{54,20},{54,0},{-54,0},{-54,-20},
              {54,-20},{54,-40},{-54,-40},{-54,40},{54,40},{54,-40}}, color={
              0,0,0}),
        Line(points={{0,40},{0,-40}}, color={0,0,0}),
        Rectangle(
          extent={{-54,40},{-28,20}},
          lineColor={0,0,0},
          fillColor={255,255,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-54,20},{-28,0}},
          lineColor={0,0,0},
          fillColor={255,255,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-54,0},{-28,-20}},
          lineColor={0,0,0},
          fillColor={255,255,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-54,-20},{-28,-40}},
          lineColor={0,0,0},
          fillColor={255,255,0},
          fillPattern=FillPattern.Solid),
        Text(
          extent={{-50,54},{-32,42}},
          textString="u[1]/[2]",
          lineColor={0,0,255}),
        Text(
          extent={{-24,54},{0,42}},
          textString="y[1]",
          lineColor={0,0,255}),
        Text(
          extent={{-2,-40},{30,-54}},
          textString="columns",
          lineColor={0,0,255}),
        Text(
          extent={{2,54},{26,42}},
          textString="y[2]",
          lineColor={0,0,255})}));
end TableGain;