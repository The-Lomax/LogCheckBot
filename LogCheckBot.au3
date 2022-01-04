#include <File.au3>
#include <Array.au3>
#include <Timers.au3>
#include <INet.au3>
#Include <WinAPI.au3>
#include <Date.au3>
#include <GuiButton.au3>
#include <GuiEdit.au3>
#include <GuiToolBar.au3>
#include <ButtonConstants.au3>
#include <FileConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <AutoitConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIFiles.au3>
#include <WindowsConstants.au3>
HotKeySet("^3", "ExitProg")
Func ExitProg()
	Exit 0
EndFunc
Global $iMessage[1], $iTime[1], $iTips[1][2]
Global $iMods[48] = [3230568,3086018,3237316,3141194,1850804,186657,205757,1084661,656077,230,671754,84,42252,290,794518,131836,208449,732509,638745,36713,224830,318030,688677,119847,301395,62910,400449,453940,97052,285933,215189,21671,276504,2534,107254,201038,1391616,327760,443,104791,18812,1199765,54128,1067156,131472,806919,296157,63559]
Global $xCord, $yCord, $iColour, $hwnd

Global $formtitle = "LogCheckBot by Lomax"
Global $program = GUICreate($formtitle, 200, 100, 1300, 181)
Global $infoLabel = GUICtrlCreateLabel("Status: ", 5, 60, 190, 20)
Global $sendbtn = GUICtrlCreateButton("Analyze", 10, 10, 60, 30)
Global $tipBreakdown = GUICtrlCreateCheckbox("Tip Breakdown", 80, 10, 105, 20)
Global $reCheck = GUICtrlCreateCheckbox("re-check current log", 80, 32, 105, 20)

WinSetOnTop($formtitle, "", 1)
GUISetState(@SW_SHOW)

Func DoIt()
	Local $speed
	$speed = 1
	ReDim $iMessage[1]

	ReDim $iTips[1][2]
	Opt("WinTitleMatchMode", 2)
	$tempTitle = "Admin panel - Gamdom.com"
	GUICtrlSetData($infoLabel, "Status: gathering logs... ")
	If WinExists( $tempTitle, "") Then
		If WinExists("tipBreakdown.txt - Notepad") Then
			WinClose("tipBreakdown.txt - Notepad")
		EndIf
		If GUICtrlRead($reCheck) <> 1 Then
			WinActivate($tempTitle)
			$hwnd = WinGetHandle($tempTitle)
			$xCord = 484
			$yCord = 415
			ControlClick($hwnd, "", "", "left", 1, 930, 708)
			Sleep(200 * $speed)
			ControlSend($hwnd, "", "", "{HOME}")
			Sleep(200 * $speed)
			MouseClickDrag("left", $xCord, $yCord, 716, 616)
			Sleep(666 * $speed)
			ControlSend($hwnd, "", "", "^+{END}")
			Sleep(150 * $speed)
			Send("^c")
			Sleep(350 * $speed)
			Local $tempText = ClipGet();
			$openFile = FileOpen("newLog.txt", 2)
			FileWrite($openFile, $tempText)
			FileClose($openFile)
		EndIf
		Sleep(500 * $speed)
		Local $contiTip, $affliates, $tipIn, $tipOut, $daily, $rainClaim, $rainTip, $depositBTC, $depositItems, $wdBTC, $wdItems, $betBalance, $jackpotBalance, $p2pDeposit, $p2pWithdraw, $ccDeposit
		Local $checkString, $sHour, $sMinute, $sSecond, $tipsInRow, $doubleTip, $userName, $userID, $input, $tempValue, $subStr, $wdBalance, $modTipIn, $modTipOut, $tipSumIn, $tipSumOut, $modTipFound, $wagered
		$doubleTip = 0
		$openFile = FileOpen("newLog.txt",0)
		If $openFile <> -1 Then
			$noLines = _FileCountLines($openFile)

			$line = StringLower(FileReadLine($openFile, 1))
			$checkString = StringInStr($line, "user activity log:", 0)
			If $checkString > 0 Then
					$userName = StringRight($line, StringLen($line) - $checkString - 18)
			EndIf

			For $i=1 To $noLines - 1
				GUICtrlSetData($infoLabel, "Status: building arrays... " & Round((($i / $noLines) * 100), 2) & "%")
				$line = StringLower(FileReadLine($openFile, $i+1))

				$checkString = StringInStr($line, "chat: ")
				If $checkString > 0 Then
				Else
					$line = StringReplace($line, " ", "")
					$checkString = StringInStr($line, "ago): ", 0, -1)
					If $checkString > 0 Then
						_ArrayAdd($iMessage, StringRight($line, StringLen($line) - $checkString - 5))
					EndIf
				EndIf
			Next
		Else
			MsgBox(0,"error", "File couldn't be open.")
		EndIf
		FileClose($openFile)

;_ArrayDisplay($iMessage)
		$betBalance = 0
		For $i = 0 to ubound($iMessage) - 1
			If Not $iMessage[$i] = "" Then
				GUICtrlSetData($infoLabel, "Status: calculating data... " & Round((($i / (ubound($iMessage) - 1)) * 100), 2) & "%")

				;wager count
				$checkString = StringInStr($iMessage[$i], ": bet ") ; checking for bet on gamemodes
				If $checkString > 0 Then ; found wagered bet
					$iStr = StringTrimLeft($iMessage[$i], $checkString + 5)
					$checkString = StringInStr($iStr, "coins")
					$strLength = StringLen($iStr)
					If $checkString > 0 Then
						$iStr = StringReplace($iStr, StringRight($iStr, $strLength - $checkString + 1), "")
					EndIf
					$wagered = $wagered + Number($iStr)
				EndIf
				;MsgBox(0,"Message", $wagered)

				$checkString = StringInStr($iMessage[$i], "coins tip") ; checking for tips
				If $checkString > 0 Then ; found tip
					For $m = 0 to UBound($iMods) - 1 ; checking for mod tips
						$checkString = StringInStr($iMessage[$i], "user " & $iMods[$m])
						If $checkString > 0 Then ; mod tip found, checking if inbound or outbound
							$modTipFound = 1
							$checkString = StringInStr($iMessage[$i], "received from user")
							If $checkString > 0 Then ; inbound tip
								$value = TrimValue($iMessage[$i])
								$modTipIn = $modTipIn + $value
								$tipSumIn = $tipSumIn + $value
								ExitLoop
							Else
								$checkString = StringInStr($iMessage[$i], "sent to user")
								If $checkString > 0 Then ; outbound tip
									$value = TrimValue($iMessage[$i])
									$modTipOut = $modTipOut + $value
									$tipSumOut = $tipSumOut + $value
									ExitLoop
								EndIf
							EndIf
						EndIf
					Next
					$checkString = StringInStr($iMessage[$i], "+1000 coins tip received from user 25") ; conti tip
					If $checkString > 0 And $modTipFound = 0 Then
						$contiTip = $contiTip + 1
					Else ; standard user tip, check if inbound or outbound
						$checkString = StringInStr($iMessage[$i], "received from user ")
						If $checkString > 0 And $modTipFound = 0 Then ; inbound tip
							$value = TrimValue($iMessage[$i])
							$tipIn = $tipIn + $value
							$tipSumIn = $tipSumIn + $value
						Else
							$checkString = StringInStr($iMessage[$i], "sent to user ")
							If $checkString > 0 And $modTipFound = 0 Then ; outbound tip
								$value = TrimValue($iMessage[$i])
								$tipOut = $tipOut + $value
								$tipSumOut = $tipSumOut + $value
							EndIf
						EndIf
					EndIf
					$modTipFound = 0
				Else
					$checkString = StringInStr($iMessage[$i], "coins complete crypto deposit")
					If $checkString > 0 Then
						$value = TrimValue($iMessage[$i])
						$depositBTC = $depositBTC + $value
					Else
						$checkString = StringInStr($iMessage[$i], "coins accepted deposit")
						If $checkString > 0 Then
							$value = TrimValue($iMessage[$i])
							$depositItems = $depositItems + $value
						Else
							$checkString = StringInStr($iMessage[$i], "coins accepted withdrawal")
							If $checkString > 0 Then
								$value = TrimValue($iMessage[$i])
								$wdItems = $wdItems + $value
							Else
								$checkString = StringInStr($iMessage[$i], "coins sent crypto withdrawal")
								If $checkString > 0 Then
									$value = TrimValue($iMessage[$i])
									$wdBTC = $wdBTC + $value
								Else
									$checkString = StringInStr($iMessage[$i], "coins rain claim")
									If $checkString > 0 Then
										$value = TrimValue($iMessage[$i])
										$rainClaim = $rainClaim + $value
									Else
										$checkString = StringInStr($iMessage[$i], "coins rain tip")
										If $checkString > 0 Then
											$value = TrimValue($iMessage[$i])
											$rainTip = $rainTip + $value
										Else
											$checkString = StringInStr($iMessage[$i], "coins daily reward")
											If $checkString > 0 Then
												$value = TrimValue($iMessage[$i])
												$daily = $daily + $value
											Else
												$checkString = StringInStr($iMessage[$i], "coins hilo")
												If $checkString > 0 Then
													If StringLeft($iMessage[$i],1) = "+" Then
														$value = TrimValue($iMessage[$i])
														$betBalance = $betBalance + $value
													ElseIf StringLeft($iMessage[$i],1) = "-" Then
														$value = TrimValue($iMessage[$i])
														$betBalance = $betBalance - $value
													EndIf
												Else
													$checkString = StringInStr($iMessage[$i], "coins roulette")
													If $checkString > 0 Then
														If StringLeft($iMessage[$i],1) = "+" Then
															$value = TrimValue($iMessage[$i])
															$betBalance = $betBalance + $value
														ElseIf StringLeft($iMessage[$i],1) = "-" Then
															$value = TrimValue($iMessage[$i])
															$betBalance = $betBalance - $value
														EndIf
													Else
														$checkString = StringInStr($iMessage[$i], "coins tradeup")
														If $checkString > 0 Then
															If StringLeft($iMessage[$i],1) = "+" Then
																$value = TrimValue($iMessage[$i])
																$betBalance = $betBalance + $value
															ElseIf StringLeft($iMessage[$i],1) = "-" Then
																$value = TrimValue($iMessage[$i])
																$betBalance = $betBalance - $value
															EndIf
														Else
															$checkString = StringInStr($iMessage[$i], "coins crash")
															If $checkString > 0 Then
																If StringLeft($iMessage[$i],1) = "+" Then
																	$value = TrimValue($iMessage[$i])
																	$betBalance = $betBalance + $value
																ElseIf StringLeft($iMessage[$i],1) = "-" Then
																	$value = TrimValue($iMessage[$i])
																	$betBalance = $betBalance - $value
																EndIf
															Else
																$checkString = StringInStr($iMessage[$i], "coins deposit tip received from user")
																If $checkString > 0 Then
																	$value = TrimValue($iMessage[$i])
																	$depositItems = $depositItems + $value
																Else
																	$checkString = StringInStr($iMessage[$i], "coins affiliate claim")
																	If $checkString > 0 Then
																		$value = TrimValue($iMessage[$i])
																		$affliates = $affliates + $value
																	Else
																		$checkString = StringInStr($iMessage[$i], "coins jackpot deposit via mp_trade")
																		If $checkString > 0 Then
																			$value = TrimValue($iMessage[$i])
																			$jackpotBalance = $jackpotBalance - $value
																			$betBalance = $betBalance - $value
																		Else
																			$checkString = StringInStr($iMessage[$i], "coins jackpot deposit via express_trade")
																			If $checkString > 0 Then
																				$value = TrimValue($iMessage[$i])
																				$jackpotBalance = $jackpotBalance - $value
																				$betBalance = $betBalance - $value
																			Else
																				$checkString = StringInStr($iMessage[$i], "coins jackpot withdraw via mp_trade")
																				If $checkString > 0 Then
																					$value = TrimValue($iMessage[$i])
																					$jackpotBalance = $jackpotBalance + $value
																					$betBalance = $betBalance + $value
																				Else
																					$checkString = StringInStr($iMessage[$i], "coins jackpot withdraw via express_trade")
																					If $checkString > 0 Then
																						$value = TrimValue($iMessage[$i])
																						$jackpotBalance = $jackpotBalance + $value
																						$betBalance = $betBalance + $value
																						$wdItems = $wdItems + $value
																					Else
																						$checkString = StringInStr($iMessage[$i], "p2p deposit completed")
																						If $checkString > 0 Then
																							$value = TrimValue($iMessage[$i])
																							$p2pDeposit = $p2pDeposit + $value
																						Else
																							$checkString = StringInStr($iMessage[$i], "p2p withdraw completed")
																							If $checkString > 0 Then
																								$value = TrimValue($iMessage[$i])
																								$p2pWithdraw = $p2pWithdraw + $value
																							Else
																								$checkString = StringInStr($iMessage[$i], "*paid* payment provider")
																								If $checkString > 0 Then
																									$value = TrimValue($iMessage[$i])
																									$ccDeposit = $ccDeposit + $value
																								EndIf
																							EndIf
																						EndIf
																					EndIf
																				EndIf
																			EndIf
																		EndIf
																	EndIf
																EndIf
															EndIf
														EndIf
													EndIf
												EndIf
											EndIf
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Next
		;_ArrayDisplay($iMessage)
		$finalIncome = ($rainClaim - $rainTip)+($tipIn-$tipOut)+($modTipIn - $modTipOut) + $daily + $betBalance + $affliates
		$wdBalance = $wdBTC + $wdItems + $p2pWithdraw - $p2pDeposit - $depositBTC - $depositItems - $ccDeposit
		GUICtrlSetData($infoLabel, "Status: complete.")
		$msgBox = MsgBox(0,"Results for: " & $userName, "Total Conti tips: " & $contiTip * 1000 & "c." & @CRLF & "Total coins claimed from referals: " & $affliates & @CRLF & "Total tips received from moderators: " & $modTipIn & @CRLF & "Total tips sent to moderators: " & $modTipOut & @CRLF & "Total tips received from other users: " & $tipIn & @CRLF & "Total tips sent to other users: " & $tipOut & @CRLF & "Coins deposited (BTC): " & $depositBTC & @CRLF & "Coins deposited (Card): " & $ccDeposit & @CRLF & "Coins deposited (Items): " & $depositItems + $p2pDeposit & @CRLF & "Coins withdrawn (BTC): " & $wdBTC & @CRLF & "Coins withdrawn (Items): " & $wdItems + $p2pWithdraw & @CRLF & "Coins claimed from rain: " & $rainClaim & @CRLF & "Coins tipped to rain: " & $rainTip & @CRLF & "Coins claimed from daily: " & $daily & @CRLF & "Total wagered: " & $wagered & @CRLF & "Balance Bets: " & $betBalance & @CRLF & @CRLF & "Overall Income: " & $finalIncome & " coins = ~" & Round(($finalIncome) * 0.666667 / 1000, 2) & "$ (Items) Or ~" & Round(($finalIncome) * 0.666667 / 1000 *0.9, 2) & "$ (BTC)" & @CRLF & "Out of which " & $wdBalance & "c has been withdrawn in total.")

		$input = GUICtrlRead($tipBreakdown)

		If $input = 1 Then
			$iTips[0][0] = "User ID"
			$iTips[0][1] = "Tip Amount"

			For $i = 0 to ubound($iMessage) - 1
				GUICtrlSetData($infoLabel, "Status: calculating tips... " & Round((($i / (ubound($iMessage) - 1)) * 100), 2) & "%")
				If Not $iMessage[$i] = "" Then
					$checkString = StringInStr($iMessage[$i], "coins tip sent to user")
					If $checkString > 0 Then
						$userID = StringRight($iMessage[$i], StringLen($iMessage[$i]) - $checkString - 21)
						For $j = 0 to UBound($iTips) - 1
							If $iTips[$j][0] = $userID Then
								$value = TrimValue($iMessage[$i])
								$iTips[$j][1] = $iTips[$j][1] + $value
								ExitLoop
							ElseIf $j = UBound($iTips) - 1 And $iTips[$j][0] <> $userID Then
								ReDim $iTips[UBound($iTips)+1][2]
								$value = TrimValue($iMessage[$i])
								$iTips[UBound($iTips)-1][0] = $userID
								$iTips[UBound($iTips)-1][1] = $value
							EndIf
						Next
					EndIf
				EndIf
			Next
			GUICtrlSetData($infoLabel, "Status: complete.")
			_ArraySort($iTips, 1, 0, 0, 1)
			$openFile = FileOpen("tipBreakdown.txt" , 2)
			FileWriteLine($openFile, "Tips breakdown for: " & $userName)
			For $i = 0 To UBound($iTips) - 1
				If StringLen($iTips[$i][0]) = 1 Then
					$subStr = "          -> "
				ElseIf StringLen($iTips[$i][0]) = 2 Then
					$subStr = "         -> "
				ElseIf StringLen($iTips[$i][0]) = 3 Then
					$subStr = "        -> "
				ElseIf StringLen($iTips[$i][0]) = 4 Then
					$subStr = "       -> "
				ElseIf StringLen($iTips[$i][0]) = 5 Then
					$subStr = "      -> "
				ElseIf StringLen($iTips[$i][0]) = 6 Then
					$subStr = "     -> "
				ElseIf StringLen($iTips[$i][0]) = 7 Then
					$subStr = "    -> "
				ElseIf StringLen($iTips[$i][0]) = 8 Then
					$subStr = "   -> "
				ElseIf StringLen($iTips[$i][0]) = 9 Then
					$subStr = "  -> "
				ElseIf StringLen($iTips[$i][0]) = 10 Then
					$subStr = " -> "
				EndIf
				FileWriteLine($openFile, $iTips[$i][0] & $subStr & $iTips[$i][1])
			Next
			FileClose($openFile)
			ShellExecute("tipBreakdown.txt")
		EndIf

		For $i = 0 to ubound($iMessage) - 1
			$iMessage[$i] = ""
			;$iTime[$i] = ""
		Next
		For $i = 0 to UBound($iTips) - 1
			$iTips[$i][0] = ""
			$iTips[$i][1] = ""
		Next
	Else
		MsgBox(0, "Error", "Error 404 - Admin panel not found")
	EndIf
EndFunc

Func TrimValue($iStr)
	If StringLeft($iStr,1) = "+" Or StringLeft($iStr,1) = "-" Then
		$iStr = StringTrimLeft($iStr,1)
	EndIf
	$checkString = StringInStr($iStr, "coins")
	$strLength = StringLen($iStr)
	If $checkString > 0 Then
		$iStr = StringReplace($iStr, StringRight($iStr, $strLength - $checkString + 1), "")
	EndIf
	$iStr = StringReplace($iStr, " ", "")
	;MsgBox(0, "", $iStr)
	$extractResult = Number($iStr)
	Return $extractResult
EndFunc

While 1
   $nMsg = GUIGetMsg()
   Switch $nMsg
	  Case $GUI_EVENT_CLOSE
		 Exit 0
	  Case $sendbtn
		 DoIt()
   EndSwitch
WEnd