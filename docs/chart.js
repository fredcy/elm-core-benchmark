function graphit(data) {
    graphat("body", data);
}

function graphat(selector, data) {
    /* fields expected in data:
       size : integer (x dimension)
       name : string (category / line)
       elmtspersec : float (y dimension)
    */
    var margin = {top: 20, right: 80, bottom: 40, left: 60},
        width = 960 - margin.left - margin.right,
        height = 500 - margin.top - margin.bottom;
    
    var x = d3.scaleLog()
        .range([0, width]);

    var y = d3.scaleLinear()
        .range([height, 0]);

    var xAxis = d3.axisBottom(x)
        .ticks(5)
	.tickFormat(d3.format(".1s"));

    var yAxis = d3.axisLeft(y)
        .tickFormat(d3.format(".2s"));

    var line = d3.line()
        .x(function(d) { return x(d.size); })
        .y(function(d) { return y(d.elmtspersec); });

    d3.select("svg").remove();  // remove any prior graph so we can re-draw it in place

    var svg = d3.select(selector).append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    x.domain(d3.extent(data, function(d) { return d.size; }));
    //y.domain(d3.extent(data, function(d) { return d.elmtspersec; }));
    y.domain([0, d3.max(data, function(d) { return d.elmtspersec; })]);

    svg.append("g")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis)
    ;

    svg.append("g")
        .call(yAxis);

    // label for Y axis, created at top-left of chart proper (`svg`) and transformed into place
    svg.append("text")
	.attr("text-anchor", "middle")
	.attr("transform",
	      "translate("+ (-margin.left + 10) + "," + (margin.top + height/2) + ") rotate(-90)")
	.text("elements / sec");

    // label for X axis
    svg.append("text")
	.attr("text-anchor", "middle")
	.attr("transform",
	      "translate("+ (width/2) + "," + (height + margin.bottom - 10) + ")")
	.text("list length");

    // group the data by test name
    var dataNest = d3.nest()
        .key(function(d) { return d.name; })
        .entries(data);

    var color = d3.scaleOrdinal(d3.schemeCategory10);

    // loop over the test names to draw a line for each
    dataNest.forEach(function(d) {
        svg.append("path")
            .attr("class", "line")
            .attr("d", line(d.values))
            .style("stroke", function() { return color(d.key); })
        ;

	// add label to right end of line
	svg.append("text")
	    .datum(function () {
		// last datum in series
		return d.values[d.values.length - 1];
	    })
	    .attr("transform", function(d2) {
		return "translate(" + x(d2.size) + "," + y(d2.elmtspersec) + ")";
	    })
	    .attr("x", 3)
	    .attr("dy", "0.35em")
	    .style("font", "16px sans-serif")
	    .text(function() { return d.key; });
    });

    // Add legend per http://zeroviscosity.com/d3-js-step-by-step/step-3-adding-a-legend

    var legendRectSize = 16;	// side of colored square
    var legendSpacing = 4;

    var legend = svg.selectAll('.legend')
        .data(color.domain())
        .enter()
        .append('g')
        .attr('class', 'legend')
        .attr('transform', function(d, i) {
            var itemheight = legendRectSize + legendSpacing;
            var offset =  height * color.domain().length / 2;
            var horz = 10; // -2 * legendRectSize;
            var vert = height - (i + 1) * itemheight - 10; // i * height - offset;
            return 'translate(' + horz + ',' + vert + ')';
        });

    legend.append('rect')
        .attr('width', legendRectSize)
        .attr('height', legendRectSize)
        .style('fill', color)
        .style('stroke', color);

    legend.append('text')
        .attr('x', legendRectSize + legendSpacing)
        .attr('y', legendRectSize - legendSpacing)
        .text(function(d) { return d; });

};
