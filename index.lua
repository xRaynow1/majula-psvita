Sound.init()
Video.init()


local musique = Sound.open("app0:/soundtrack.oga")
local police = Font.load("app0:/font.TTF")
Font.setPixelSizes(police, 28)

Sound.play(musique, LOOP)
Video.open("app0:/background.mp4", true)
local chrono = Timer.new()


local duree_fade_debut = 2500


local particules = {}
local max_particules = 450


local function afficherSousTitre(texte, temps, debut, duree, fade)
    local fin = debut + duree
    if temps >= debut and temps < fin then
        local alpha = 255
        if temps < debut + fade then
            alpha = math.floor(255 * ((temps - debut) / fade))
        elseif temps > fin - fade then
            alpha = math.floor(255 * ((fin - temps) / fade))
        end

        if alpha < 0 then alpha = 0 end
        if alpha > 255 then alpha = 255 end

        local largeur
        if Font.getTextWidth then
            largeur = Font.getTextWidth(police, texte)
        else
            largeur = #texte * 14
        end
        local x = math.floor((960 - largeur) / 2)
        local y = 470

        Font.print(police, x + 2, y + 2, texte, Color.new(0, 0, 0, alpha))
        Font.print(police, x, y, texte, Color.new(255, 255, 255, alpha))
    end
end


while true do
    Graphics.initBlend()
    Screen.clear()

    local temps = Timer.getTime(chrono)


    local frame = Video.getOutput()
    if frame ~= 0 then
        Graphics.drawImage(0, 0, frame)
    end


    if temps < duree_fade_debut then
        local fade_alpha = math.floor(255 * (1 - (temps / duree_fade_debut)))
        Graphics.fillRect(0, 960, 0, 544, Color.new(0, 0, 0, fade_alpha))
    end


    local tx, ty = Controls.readTouch()
    if tx ~= nil then
        for j = 1, 4 do
            table.insert(particules, {
                x = tx + math.random(-6, 6),
                y = ty + math.random(-6, 6),
                vx = (math.random() - 0.5) * 0.7,
                vy = 0.4 + math.random() * 0.9,
                taille = math.random(1, 3),
                phase = math.random() * 6.28,
                ondul = 0.004 + math.random() * 0.006,
                debut = temps,
                duree = math.random(700, 1200)
            })

            if #particules > max_particules then
                table.remove(particules, 1)
            end
        end
    end


    for i = #particules, 1, -1 do
        local p = particules[i]
        local age = temps - p.debut
        local ratio = age / p.duree

        if ratio >= 1 then
            table.remove(particules, i)
        else
            p.x = p.x + p.vx + math.sin(age * p.ondul + p.phase) * 0.65
            p.y = p.y - p.vy

            local scintillement = 0.7 + math.random() * 0.3
            local alpha = math.floor(255 * (1 - ratio) * scintillement)
            local taille_actuelle = p.taille * (1 - ratio * 0.5)

            if ratio < 0.2 then
                local halo = Color.new(255, 90, 10, math.floor(alpha * 0.35))
                local coeur = Color.new(255, 235, 140, alpha)
                Graphics.fillCircle(p.x, p.y, taille_actuelle * 2.2, halo)
                Graphics.fillCircle(p.x, p.y, taille_actuelle, coeur)
            elseif ratio < 0.65 then
                local halo = Color.new(220, 45, 5, math.floor(alpha * 0.3))
                local coeur = Color.new(255, 115, 15, alpha)
                Graphics.fillCircle(p.x, p.y, taille_actuelle * 1.8, halo)
                Graphics.fillCircle(p.x, p.y, taille_actuelle, coeur)
            else
                local prog = (ratio - 0.65) / 0.35
                local r = math.floor(200 - prog * 120)
                local g = math.floor(35 - prog * 25)
                local braise_morte = Color.new(r, g, 5, alpha)
                Graphics.fillCircle(p.x, p.y, taille_actuelle, braise_morte)
            end
        end
    end


    afficherSousTitre("Thou hast fought well, weary warrior.", temps, 0, 6000, 1000)
    afficherSousTitre("Come, rest awhile.", temps, 6500, 5000, 1000)

    Graphics.termBlend()
    Screen.flip()


    local pad = Controls.read()
    if Controls.check(pad, SCE_CTRL_START) then
        break
    end
end


Sound.pause(musique)
Timer.destroy(chrono)
System.exit()