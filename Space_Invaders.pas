program Space_Invaders;

uses GraphABC, Events, Timers, CRT, Sounds;

type

   TAlien = record
      x,y,f_o,f_c: integer;
      alive,fire: boolean;
   end;
   TGun = record
      x,pic,expl: integer;
   end;
   TBullet = record
      x,y,pic: integer;
      shot: boolean;
   end;
   
const

   dx = 17;
   dy = 14;
   moveX = 7;
   moveY = 19;

var

   aliens: array [1..5,1..11] of TAlien;
   Gun: TGun;
   Bullet,ABullet: TBullet;
   forma,explosion,score: integer;
   TMove,TMove_Bullet,TAB: Timer;
   Direction: (left,right);
   MinC,MaxC,MinS,MaxS,lives,Level: byte;
   type_of_game: (menu, game, go);
   alien_die,alien_move,players_die,players_shot: sound;

//Обработка перехода на следующий уровень сложности
procedure Next_Level;
var
   i,k: integer;
begin
   TMove.Stop;
   TMove_Bullet.Stop;
   TAB.Stop;
   FillRect(ABullet.x,ABullet.y,ABullet.x+2,ABullet.y+7);
   ABullet.shot:=false;

   sleep(1000);

   MinC:=1; MaxC:=11;
   MinS:=1; MaxS:=5;
   forma:=1;
   inc(Level);
   Direction:=right;

   for i:=1 to 5 do
      for k:=1 to 11 do
      begin
         aliens[i,k].x:=96+(22+dx)*(k-1);
         aliens[i,k].y:=80+(16+dy)*(Level-1)+(16+dy)*(i-1);
         aliens[i,k].f_o:=LoadPicture('.\Data\Pictures\alien_o.bmp');
         aliens[i,k].f_c:=LoadPicture('.\Data\Pictures\alien_c.bmp');
         aliens[i,k].alive:=true;
         if i = 5 then aliens[i,k].fire:=true;
      end;

   TMove.Start;
end;

//Процедура управления пушкой
procedure KeyDown(key: integer);
begin
   if type_of_game = game then
      if key<>VK_Space then
      begin
         FillRect(Gun.x,513,Gun.x+30,529);
         case key of
            VK_Right: if Gun.x+34<650 then inc(Gun.x,10);
            VK_Left:  if Gun.x-10>0 then dec(Gun.x,10);
         end;
         DrawPicture(Gun.pic,Gun.x,513);
         redraw;
      end
      else
         if not Bullet.shot then
         begin
            Bullet.shot:=true;
            Bullet.x:=Gun.x+14;
            Bullet.y:=503;
            players_shot.Play;
            TMove_Bullet.Start;
         end;
end;

//Отрисовка статусбара(очки и жизни)
procedure StatusBar;
begin
   GotoXY(8,1);
   write('Score   ',score);
   GotoXY(60,1);
   write('Lives   ',lives);
end;

//Обработка нажатия кнопки Start
procedure MouseUp(x,y,mb: integer);
begin
   if (type_of_game = menu) and ( (x>=214) and (y>=347) ) and ( (x<=421) and (y<=438) ) then type_of_game:=game;
end;

//Подготовка игры
procedure Init_Game;
var
   i,k: integer;
begin

   MinC:=1; MaxC:=11;
   MinS:=1; MaxS:=5;
   forma:=1;
   lives:=3;
   score:=0;
   Level:=1;
   Direction:=right;
   type_of_game:=menu;

   SetWindowWidth(650);
   SetWindowHeight(530);
   CenterWindow;
   HideCursor;
   SetWindowCaption('Space Invaders');
   LockDrawing;

   ClearWindow(clBlack);
   SetBrushColor(clBlack);
   OnKeyDown:=KeyDown;
   OnMouseUp:=MouseUp;
   
   for i:=1 to 5 do
      for k:=1 to 11 do
      begin
         aliens[i,k].x:=96+(22+dx)*(k-1);
         aliens[i,k].y:=80+(16+dy)*(Level-1)+(16+dy)*(i-1);
         aliens[i,k].f_o:=LoadPicture('.\Data\Pictures\alien_o.bmp');
         aliens[i,k].f_c:=LoadPicture('.\Data\Pictures\alien_c.bmp');
         aliens[i,k].alive:=true;
         if i = 5 then aliens[i,k].fire:=true;
      end;
      
   Gun.pic:=LoadPicture('.\Data\Pictures\gun.bmp');
   Gun.expl:=LoadPicture('.\Data\Pictures\gunexplosion.bmp');
   Gun.x:=361;
   
   Bullet.pic:=LoadPicture('.\Data\Pictures\bullet.bmp');
   Bullet.shot:=false;
   
   explosion:=LoadPicture('.\Data\Pictures\alienexplosion.bmp');
   
   ABullet.pic:=LoadPicture('.\Data\Pictures\abullet.bmp');
   ABullet.shot:=false;
   
   SetFontName('Bauhaus 93');
   TextColor(15);
   TextBackGround(0);
   SetFontSize(20);
   
   alien_die:=Sound.Create('.\Data\Sounds\aliendie.wav');
   players_die:=Sound.Create('.\Data\Sounds\playerdie.wav');
   players_shot:=Sound.Create('.\Data\Sounds\playershot.wav');
      
end;


//Создание меню
procedure Main_menu;
begin
   LoadWindow('.\Data\Pictures\menu.bmp');
   redraw;
   repeat until type_of_game = game;
   ClearWindow(clBlack);
   KeyDown(VK_Left);
end;

//Процедура выстрела пришельца
procedure Shot_Alien;
var
   n,i: integer;
begin
   if (not ABullet.shot) and (1+random(100)<70) then
   begin
      repeat
         n:=MinC+random(MaxC-MinC+1);
         for i:=MinS to MaxS do
            if aliens[i,n].alive and aliens[i,n].fire then
            begin
               ABullet.x:=aliens[i,n].x+10;
               ABullet.y:=aliens[i,n].y+18;
               ABullet.shot:=true;
            end;
      until ABullet.shot=true;
      TAB.Start;
   end;
end;

//Обработка захвата планеты пришельцами
procedure Game_Over;
begin
   TMove.Stop;
   TMove_Bullet.Stop;
   type_of_game:=go;
   GotoXY(24,14);
   TextColor(4);
   SetFontSize(40);
   write('GAME OVER');
end;

//Движение пришельцев
procedure Move_Aliens;
var
   i,k: integer;
begin

   FillRect(aliens[1,1].x,aliens[1,1].y,aliens[5,11].x+22,aliens[5,11].y+16);
   
   if Direction = right then
      if aliens[1,MaxC].x+22+moveX<=650 then
         for i:=1 to 5 do
            for k:=1 to 11 do
               inc(aliens[i,k].x,moveX)
      else
      begin
         for i:=1 to 5 do
            for k:=1 to 11 do
               inc(aliens[i,k].y,moveY);
         Direction:=left;
      end
   else
      if aliens[1,MinC].x-moveX>=0 then
         for i:=1 to 5 do
            for k:=1 to 11 do
               dec(aliens[i,k].x,moveX)
      else
      begin
         for i:=1 to 5 do
            for k:=1 to 11 do
               inc(aliens[i,k].y,moveY);
         Direction:=right;
      end;
      
   inc(forma);
   
   if forma mod 2 = 0 then
   begin
      for i:=1 to 5 do
         for k:=1 to 11 do
            if aliens[i,k].alive then DrawPicture(aliens[i,k].f_c,aliens[i,k].x,aliens[i,k].y);
   end
   else
   begin
      for i:=1 to 5 do
         for k:=1 to 11 do
            if aliens[i,k].alive then DrawPicture(aliens[i,k].f_o,aliens[i,k].x,aliens[i,k].y);
   end;
   
   redraw;
   
   if aliens[MaxS,MinC+random(MaxC-MinC+1)].y>430 then Game_Over;
   
   Shot_Alien;
end;

//Обработка уничтожения корабля
procedure Destruction(x,y: integer);
var
   i,k,l: integer;
begin
   FillRect(x,y,x+22,y+16);
   DrawPicture(explosion,x,y);
   redraw;
   alien_die.Play;
   inc(score,20);
   StatusBar;
   
   k:=0; l:=0;
   for i:=MinS to MaxS do
   begin
      if not aliens[i,MinC].alive then inc(k);
      if not aliens[i,MaxC].alive then inc(l);
   end;
   if k = i then inc(MinC);
   if l = i then dec(MaxC);
   
   k:=0; l:=0;
   for i:=MinC to MaxC do
   begin
      if not aliens[MinS,i].alive then inc(k);
      if not aliens[MaxS,i].alive then inc(l);
   end;
   if k = i then inc(MinS);
   if l = i then dec(MaxS);
   
   sleep(10);
   FillRect(x,y,x+22,y+16);
   redraw;
   
   l:=0;
   for i:=1 to 5 do
      for k:=1 to 11 do
         if not aliens[i,k].alive then inc(l);
   if l = 55 then Next_Level;

end;

//Движение пули пришельца
procedure Move_Bullet_Alien;
var
   hit: boolean;
begin
   hit:=false;
   FillRect(ABullet.x,ABullet.y,ABullet.x+2,ABullet.y+7);
   if (ABullet.x>=Gun.x) and (ABullet.x<=Gun.x+30) and (ABullet.y+7>513) then hit:=true;
   if (ABullet.y<530) and (not hit) then
   begin
      inc(ABullet.y,5);
      DrawPicture(ABullet.pic,ABullet.x,ABullet.y);
   end
   else
   begin
      ABullet.shot:=false;
      TAB.Stop;
      if hit then
      begin
         FillRect(Gun.x,513,Gun.x+30,529);
         DrawPicture(Gun.expl,Gun.x,513);
         redraw;
         players_die.Play;
         Sleep(players_die.Length);
         players_die.Stop;
         players_die.Rewind;
         FillRect(Gun.x,513,Gun.x+30,529);
         DrawPicture(Gun.pic,Gun.x,513);
         dec(lives);
         StatusBar;
         if lives = 0 then Game_Over;
      end;
   end;
   redraw;
end;

//Движение пули
procedure Move_Bullet;
var
   k,i,l,m: integer;
   hit: boolean;
begin
   hit:=false;
   FillRect(Bullet.x,Bullet.y,Bullet.x+2,Bullet.y+7);
   for i:=1 to 5 do
   begin
      for k:=1 to 11 do
         if (Bullet.x>aliens[i,k].x) and (Bullet.x<aliens[i,k].x+22) and (Bullet.y<=aliens[i,k].y+16) and (Bullet.y>=aliens[i,k].y) and (aliens[i,k].alive) then
         begin
            l:=aliens[i,k].x; m:=aliens[i,k].y;
            hit:=true;
            aliens[i,k].alive:=false;
            aliens[i,k].fire:=false;
            if i>1 then aliens[i-1,k].fire:=true;
            break;
         end;
      if hit then break;
   end;
   if (Bullet.y>28) and (not hit) then
   begin
      dec(Bullet.y,5);
      DrawPicture(Bullet.pic,Bullet.x,Bullet.y);
   end
   else
   begin
      Bullet.shot:=false;
      TMove_Bullet.Stop;
      if hit then Destruction(l,m);
   end;
   redraw;
end;

//Начало программы
begin
   randomize;
   
   Init_Game;
   
   Main_menu;
   StatusBar;
   
   TMove:=Timer.Create(400,Move_Aliens);
   TMove_Bullet:=Timer.Create(15,Move_Bullet);
   TMove_Bullet.Stop;
   TAB:=Timer.Create(15,Move_Bullet_Alien);
   TAB.Stop;

end.
