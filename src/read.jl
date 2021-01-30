struct XVG
    Data::Array{Array{Float64,1},1}
    x_label::SubString{String}
    y_label::SubString{String}
    plot_labels
    title::SubString{String}
end

function read_xvg(path::AbstractString)
    a = readlines(path)
    plot_atributes = filter(x->startswith(x,"@"),a)
    if length(plot_atributes) >= 11
            if length(plot_atributes) > 11
                plot_label = Array{AbstractString,1}(undef,length(plot_atributes)-11 + 1)
                for i in 11:length(plot_atributes)
                    plot_label[i-10] = replace(replace(replace(strip(split(plot_atributes[i],"legend")[2]),"\\s"=>"_"),"\""=>""),"\\N"=>"") 
                end
                String.(plot_label)
            else
                plot_label = split(plot_atributes[11],"legend")[2][3:end-1]
            end            
    else
        plot_label = split(plot_atributes[1],"title")[2][3:end-1]
    end
    title = split(plot_atributes[1],"title")[2][3:end-1]
    x_label = split(plot_atributes[2],"label")[2][3:end-1]
    y_label = split(plot_atributes[3],"label")[2][3:end-1]
    dp = map(x->parse.(Float64,x),split.(filter(x->startswith(x," "),a)))
    
    return XVG(dp,x_label,y_label,plot_label,title)
end


using RecipesBase

@recipe function f(a::XVG)
    label --> false
    xguide --> a.x_label
    yguide --> a.y_label
    title --> a.title
    legend --> :outertopright
    
    if typeof(a.plot_labels) != SubString{String}
        labels --> reshape(a.plot_labels,(1,length(a.plot_labels)))
    else
        labels --> a.plot_labels
    end
    @series begin
        if a.Data[1] |> length == 2
            getindex.(a.Data,1),getindex.(a.Data,2)
        else
            getindex.(a.Data,1),[getindex.(a.Data,2), getindex.(a.Data,3),getindex.(a.Data,4),getindex.(a.Data,5)]
        end
        
    end
end