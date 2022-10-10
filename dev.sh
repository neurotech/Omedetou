echo "Building Omedetou and installing to WoW directory."

touch Omedetou.toc.tmp

cat Omedetou.toc > Omedetou.toc.tmp

sed -i "s/@project-version@/$(git describe --abbrev=0)/g" Omedetou.toc.tmp

mkdir -p /h/games/World\ of\ Warcraft/_classic_/Interface/AddOns/Omedetou/

cp *.lua /h/games/World\ of\ Warcraft/_classic_/Interface/AddOns/Omedetou/

cp Omedetou.toc.tmp /h/games/World\ of\ Warcraft/_classic_/Interface/AddOns/Omedetou/Omedetou.toc

rm Omedetou.toc.tmp

echo "Complete."